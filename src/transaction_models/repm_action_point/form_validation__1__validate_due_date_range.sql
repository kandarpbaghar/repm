/*
project: repm
object_type: T
object_name: repm_action_point
event_type: form_validation
function_name: validate_due_date_range
form_no: 1
field_name:
business_logic: Due Date must be within parent activity planned start and end dates.
                Performs a DB lookup on repm_activity as a server-side safeguard.
                Returns 1 = valid, 0 = out of range.
*/
CREATE OR REPLACE FUNCTION validate_due_date_range(
    p_activity_id    TEXT,  -- (1.ACTIVITY_ID)
    p_due_dt         DATE,  -- (1.DUE_DT)
    p_plan_start_dt  DATE,  -- (1.ACT_PLAN_START_DT)
    p_plan_end_dt    DATE   -- (1.ACT_PLAN_END_DT)
) RETURNS INTEGER AS $$
DECLARE
    v_start DATE := p_plan_start_dt;
    v_end   DATE := p_plan_end_dt;
BEGIN
    IF p_due_dt IS NULL OR p_activity_id IS NULL THEN
        RETURN 1;
    END IF;

    -- If item_change did not fill the dates, fetch from DB
    IF v_start IS NULL OR v_end IS NULL THEN
        SELECT plan_start_dt, plan_end_dt
          INTO v_start, v_end
          FROM repm_activity
         WHERE TRIM(activity_id) = TRIM(p_activity_id);
    END IF;

    IF v_start IS NULL OR v_end IS NULL THEN
        RETURN 1; -- activity has no plan dates; skip
    END IF;

    RETURN CASE WHEN p_due_dt BETWEEN v_start AND v_end THEN 1 ELSE 0 END;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$ LANGUAGE plpgsql;
