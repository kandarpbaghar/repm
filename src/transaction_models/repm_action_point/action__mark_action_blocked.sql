/*
project: repm
object_type: T
object_name: repm_action_point
event_type: action
function_name: mark_action_blocked
form_no:
field_name:
action_name: mark_blocked
business_logic: Set STATUS=BL, require BLOCKING_REASON and notify
*/
CREATE OR REPLACE FUNCTION mark_action_blocked(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_action_id       TEXT := TRIM(p->>'ACTION_ID');
    v_blocking_reason TEXT := TRIM(COALESCE(p->>'BLOCKING_REASON', ''));
    v_status          TEXT;
BEGIN
    IF v_blocking_reason = '' THEN
        RETURN '{"error": "Blocking Reason is required to mark an action point as Blocked."}'::jsonb;
    END IF;

    SELECT status INTO v_status
      FROM repm_action_point
     WHERE TRIM(action_id) = v_action_id;

    IF NOT FOUND THEN
        RETURN '{"error": "Action point not found."}'::jsonb;
    END IF;

    IF v_status = 'DN' THEN
        RETURN '{"error": "Cannot block a Done action point."}'::jsonb;
    END IF;

    IF v_status = 'CN' THEN
        RETURN '{"error": "Cannot block a Cancelled action point."}'::jsonb;
    END IF;

    UPDATE repm_action_point
       SET status          = 'BL',
           blocking_reason = v_blocking_reason,
           chg_date        = CURRENT_DATE,
           chg_user        = COALESCE(p->>'_logged_in_user', 'system'),
           chg_term        = COALESCE(p->>'_logged_in_terminal', '')
     WHERE TRIM(action_id) = v_action_id;

    RETURN '{"message": "Action point marked as Blocked."}'::jsonb;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql;
