/*
project: repm
object_type: T
object_name: repm_employee
event_type: cross_update
function_name: block_new_assignments
form_no:
field_name:
business_logic: Prevent deactivation when open action points are still assigned to this employee
*/

CREATE OR REPLACE FUNCTION block_new_assignments(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_emp_code    TEXT;
    v_new_status  TEXT;
    v_old_status  TEXT;
    v_open_count  INTEGER;
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

    -- Only enforce on Active → Inactive transition
    IF v_old_status IS NULL OR v_old_status = 'I' THEN
        RETURN NULL;
    END IF;

    -- Count open (Pending / In-Progress) action points assigned to this employee
    SELECT COUNT(*) INTO v_open_count
    FROM repm_action_point
    WHERE assigned_emp_code = v_emp_code
      AND status IN ('PE', 'IP');

    IF v_open_count > 0 THEN
        RETURN jsonb_build_object(
            'error',
            'Cannot deactivate employee ' || v_emp_code || '. ' ||
            v_open_count || ' open action point(s) (Pending / In-Progress) are still assigned. ' ||
            'Please reassign or close them before deactivating this employee.'
        );
    END IF;

    RETURN NULL;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('error', 'Deactivation check failed: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql;
