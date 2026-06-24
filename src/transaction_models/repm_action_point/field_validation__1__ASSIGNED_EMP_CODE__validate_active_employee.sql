/*
project: repm
object_type: T
object_name: repm_action_point
event_type: field_validation
function_name: validate_active_employee
form_no: 1
field_name: ASSIGNED_EMP_CODE
business_logic: Assigned employee must be Active
                Checks repm_employee.status = 'A'.
                Returns 1 = valid (Active), 0 = invalid.
*/
CREATE OR REPLACE FUNCTION validate_active_employee(
    p_assigned_emp_code TEXT   -- (1.ASSIGNED_EMP_CODE)
) RETURNS INTEGER AS $$
DECLARE
    v_status CHAR(1);
BEGIN
    IF p_assigned_emp_code IS NULL OR TRIM(p_assigned_emp_code) = '' THEN
        RETURN 1; -- mandatory check handles blank
    END IF;

    SELECT status INTO v_status
      FROM repm_employee
     WHERE TRIM(emp_code) = TRIM(p_assigned_emp_code);

    IF NOT FOUND THEN
        RETURN 1; -- must_exist_in handles missing row
    END IF;

    RETURN CASE WHEN v_status = 'A' THEN 1 ELSE 0 END;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$ LANGUAGE plpgsql;
