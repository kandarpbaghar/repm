/*
project: repm
object_type: T
object_name: repm_employee
event_type: action
function_name: soft_delete_employee
form_no:
field_name:
action_name: delete
business_logic: If references exist, set Status to Inactive instead of hard delete
*/

CREATE OR REPLACE FUNCTION soft_delete_employee(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_emp_code   TEXT;
    v_ap_count   INTEGER;
    v_act_count  INTEGER;
    v_proj_count INTEGER;
    v_total      INTEGER;
BEGIN
    v_emp_code := TRIM(p->>'EMP_CODE');

    -- Count references in action points
    SELECT COUNT(*) INTO v_ap_count
    FROM repm_action_point
    WHERE assigned_emp_code = v_emp_code;

    -- Count references in activities
    SELECT COUNT(*) INTO v_act_count
    FROM repm_activity
    WHERE assigned_emp_code = v_emp_code;

    -- Count references as project manager
    SELECT COUNT(*) INTO v_proj_count
    FROM repm_project
    WHERE pm_emp_code = v_emp_code;

    v_total := COALESCE(v_ap_count, 0) + COALESCE(v_act_count, 0) + COALESCE(v_proj_count, 0);

    IF v_total > 0 THEN
        -- Soft delete: set status to Inactive, cannot permanently delete
        UPDATE repm_employee
        SET status   = 'I',
            chg_date = NOW(),
            chg_user = COALESCE(p->>'ADD_USER', 'SYSTEM')
        WHERE emp_code = v_emp_code;

        RETURN jsonb_build_object(
            'message',
            'Employee ' || v_emp_code ||
            ' has active references (' || v_total || ' record(s) across projects, activities and action points). ' ||
            'Employee has been marked Inactive instead of permanently deleted.'
        );
    ELSE
        -- No references — hard delete is safe
        DELETE FROM repm_emp_experience WHERE emp_code = v_emp_code;
        DELETE FROM repm_employee       WHERE emp_code = v_emp_code;

        RETURN jsonb_build_object(
            'message',
            'Employee ' || v_emp_code || ' and all associated experience records have been permanently deleted.'
        );
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('error', 'Delete failed: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql;
