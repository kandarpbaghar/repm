/*
project: repm
object_type: T
object_name: repm_employee
event_type: cross_update
function_name: flag_open_action_points
form_no:
field_name:
business_logic: On deactivation, flag Blocked action points assigned to this employee for reassignment
*/

CREATE OR REPLACE FUNCTION flag_open_action_points(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_emp_code    TEXT;
    v_new_status  TEXT;
    v_old_status  TEXT;
    v_flagged     INTEGER;
BEGIN
    v_emp_code   := TRIM(p->>'EMP_CODE');
    v_new_status := TRIM(p->>'STATUS');

    -- Only run when deactivating
    IF v_new_status IS DISTINCT FROM 'I' THEN
        RETURN NULL;
    END IF;

    -- Read current stored status (before this save commits)
    SELECT status INTO v_old_status
    FROM repm_employee
    WHERE emp_code = v_emp_code;

    -- Only run on Active → Inactive transition
    IF v_old_status IS NULL OR v_old_status = 'I' THEN
        RETURN NULL;
    END IF;

    -- Append a reassignment note to Blocked action points still assigned to this employee
    UPDATE repm_action_point
    SET remarks  = CASE
                     WHEN remarks IS NULL OR TRIM(remarks) = ''
                     THEN '[Needs Reassignment: Employee ' || v_emp_code || ' deactivated on ' || TO_CHAR(NOW(), 'DD-Mon-YYYY') || ']'
                     ELSE remarks || ' | [Needs Reassignment: Employee ' || v_emp_code || ' deactivated on ' || TO_CHAR(NOW(), 'DD-Mon-YYYY') || ']'
                   END,
        chg_date = NOW(),
        chg_user = COALESCE(NULLIF(TRIM(p->>'ADD_USER'), ''), 'SYSTEM')
    WHERE assigned_emp_code = v_emp_code
      AND status = 'BL';

    GET DIAGNOSTICS v_flagged = ROW_COUNT;

    RETURN NULL;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('error', 'Flag action points failed: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql;
