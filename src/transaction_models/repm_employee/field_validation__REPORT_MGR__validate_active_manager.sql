/*
project: repm
object_type: T
object_name: repm_employee
event_type: field_validation
function_name: validate_active_manager
form_no:
field_name: REPORT_MGR
business_logic: Reporting Manager must be an existing Active employee
NOTE: This function is no longer referenced in the model — the check is now handled by
      a must_exist_in_master builtin validator with STATUS='A' condition. Kept as a stub.
*/

CREATE OR REPLACE FUNCTION validate_active_manager(p jsonb) RETURNS jsonb AS $$
BEGIN
    -- Replaced by must_exist_in_master builtin in the model.
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
