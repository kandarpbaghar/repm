/*
project: repm
object_type: T
object_name: repm_action_point
event_type: action
function_name: cancel_action_point
form_no:
field_name:
action_name: cancel
business_logic: Set STATUS=CN; excluded from progress computation
*/
CREATE OR REPLACE FUNCTION cancel_action_point(p jsonb) RETURNS jsonb AS $$
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

    IF v_status = 'CN' THEN
        RETURN '{"error": "Action point is already Cancelled."}'::jsonb;
    END IF;

    IF v_status = 'DN' THEN
        RETURN '{"error": "Cannot cancel a Done action point."}'::jsonb;
    END IF;

    UPDATE repm_action_point
       SET status   = 'CN',
           chg_date = CURRENT_DATE,
           chg_user = COALESCE(p->>'_logged_in_user', 'system'),
           chg_term = COALESCE(p->>'_logged_in_terminal', '')
     WHERE TRIM(action_id) = v_action_id;

    RETURN '{"message": "Action point cancelled."}'::jsonb;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql;
