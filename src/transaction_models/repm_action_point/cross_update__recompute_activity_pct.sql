/*
project: repm
object_type: T
object_name: repm_action_point
event_type: cross_update
function_name: recompute_activity_pct
form_no:
field_name:
business_logic: Recompute parent activity % complete from Done vs non-cancelled action points.
                pct_complete = (DN count / non-CN count) * 100.
*/
CREATE OR REPLACE FUNCTION recompute_activity_pct(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_activity_id TEXT := TRIM(p->>'ACTIVITY_ID');
    v_total       INTEGER;
    v_done        INTEGER;
    v_pct         NUMERIC(5,2);
BEGIN
    IF v_activity_id IS NULL OR v_activity_id = '' THEN
        RETURN '{}'::jsonb;
    END IF;

    SELECT COUNT(*) FILTER (WHERE status <> 'CN'),
           COUNT(*) FILTER (WHERE status = 'DN')
      INTO v_total, v_done
      FROM repm_action_point
     WHERE TRIM(activity_id) = v_activity_id;

    v_pct := CASE WHEN COALESCE(v_total, 0) = 0 THEN 0
                  ELSE ROUND((v_done::NUMERIC / v_total) * 100, 2)
             END;

    UPDATE repm_activity
       SET pct_complete = v_pct,
           chg_date     = CURRENT_DATE,
           chg_user     = COALESCE(p->>'_logged_in_user', 'system')
     WHERE TRIM(activity_id) = v_activity_id;

    RETURN jsonb_build_object('activity_id', v_activity_id, 'pct_complete', v_pct);

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql;
