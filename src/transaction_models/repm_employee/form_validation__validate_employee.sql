/*
project: repm
object_type: T
object_name: repm_employee
event_type: form_validation
function_name: validate_employee
form_no:
field_name:
business_logic: Validate unique code/email, mobile length, and active reporting manager
NOTE: This function is no longer referenced in the model — uniqueness and format checks
      are now handled by builtin validators (must_be_unique, expression). Kept as a stub.
*/

CREATE OR REPLACE FUNCTION validate_employee(p jsonb) RETURNS jsonb AS $$
BEGIN
    -- All checks are now handled by builtin validators in the model.
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
