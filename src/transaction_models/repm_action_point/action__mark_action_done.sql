/*
project: repm
object_type: T
object_name: repm_action_point
event_type: action
function_name: mark_action_done
form_no:
field_name:
action_name: mark_done
business_logic: Set STATUS=DN, stamp COMPLETED_DT=today() and trigger roll-up
*/
CREATE OR REPLACE FUNCTION mark_action_done(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_action_id TEXT := TRIM(p->>'ACTION_ID');
    v_status    TEXT;
BEGIN
    SELECT status INTO v_status
      FROM repm_action_point
     WHERE TRIM(action_id) = v_action_id;

    IF NOT FOUND THEN
        RETURN '{"error": "Action point not found."}'::jsonb;
    END IF;

    IF v_status = 'DN' THEN
        RETURN '{"error": "Action point is already marked as Done."}'::jsonb;
    END IF;

    IF v_status = 'CN' THEN
        RETURN '{"error": "Cannot mark a Cancelled action point as Done."}'::jsonb;
    END IF;

    UPDATE repm_action_point
       SET status       = 'DN',
           completed_dt = CURRENT_DATE,
           chg_date     = CURRENT_DATE,
           chg_user     = COALESCE(p->>'_logged_in_user', 'system'),
           chg_term     = COALESCE(p->>'_logged_in_terminal', '')
     WHERE TRIM(action_id) = v_action_id;

    RETURN '{"message": "Action point marked as Done."}'::jsonb;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql;
