/******************************************************************************
 * Object Name   : REPM_ACTION_POINT
 * Event Type    : Form Validation (On-Save)
 * Form Number   : 1 (Action Point)
 * Field Name    : SEQ_NO
 * Business Logic: Action Point Sequence Number must be unique within the scope
 *                 of an Activity (i.e. for the same combination of PROJ_CODE,
 *                 PHASE_ID, TASK_ID, ACTIVITY_ID). The current record being
 *                 edited (identified by ACTION_ID) is excluded from the
 *                 uniqueness check to allow re-saving the same row.
 * Function Name : validate_seq_unique
 * Returns       : 1 -> Valid (sequence is unique or inputs incomplete to check)
 *                 0 -> Invalid (duplicate sequence found within the activity)
 * Note          : This function is READ-ONLY. It performs NO insert/update/delete.
 ******************************************************************************/
CREATE OR REPLACE FUNCTION validate_seq_unique
(
    p_action_id     IN  CHAR,      --(1.ACTION_ID)     Current Action Point ID (to exclude self on edit)
    p_proj_code     IN  CHAR,      --(1.PROJ_CODE)     Project Code - scope for uniqueness
    p_phase_id      IN  CHAR,      --(1.PHASE_ID)      Phase ID - scope for uniqueness
    p_task_id       IN  CHAR,      --(1.TASK_ID)       Task ID - scope for uniqueness
    p_activity_id   IN  CHAR,      --(1.ACTIVITY_ID)   Activity ID - scope for uniqueness
    p_seq_no        IN  NUMBER     --(1.SEQ_NO)        Sequence number to validate
)
RETURN NUMBER
IS
    -- Local variable to hold the count of conflicting rows in REPM_ACTION_POINT
    v_count    NUMBER := 0;
    -- Final validation result flag (1 = valid, 0 = invalid)
    v_result   NUMBER := 1;
BEGIN
    -- -----------------------------------------------------------------
    -- Step 1: Guard clause - if mandatory scope keys or sequence number
    -- are missing, we cannot meaningfully perform a uniqueness check.
    -- In such cases we treat the data as "valid" from this function's
    -- perspective; mandatory-field validation should be handled by
    -- separate field-level validators.
    -- -----------------------------------------------------------------
    IF p_seq_no       IS NULL
       OR p_proj_code   IS NULL
       OR p_phase_id    IS NULL
       OR p_task_id     IS NULL
       OR p_activity_id IS NULL
    THEN
        RETURN 1;
    END IF;

    -- -----------------------------------------------------------------
    -- Step 2: Check for any OTHER action point row in the same activity
    -- scope that already uses this SEQ_NO. We exclude the current row
    -- (by ACTION_ID) so that editing an existing record does not flag
    -- itself as a duplicate. NVL is used so that a brand-new record
    -- (p_action_id IS NULL) still works in the comparison.
    -- ROWNUM = 1 is used for performance - we only need to know if
    -- at least one conflicting row exists.
    -- -----------------------------------------------------------------
    SELECT COUNT(1)
      INTO v_count
      FROM repm_action_point ap
     WHERE ap.proj_code    = p_proj_code
       AND ap.phase_id     = p_phase_id
       AND ap.task_id      = p_task_id
       AND ap.activity_id  = p_activity_id
       AND ap.seq_no       = p_seq_no
       AND NVL(ap.action_id, '~') <> NVL(p_action_id, '~')
       AND ROWNUM          = 1;

    -- -----------------------------------------------------------------
    -- Step 3: Translate the count into the validation flag.
    -- If a conflicting row was found -> invalid (0); else valid (1).
    -- -----------------------------------------------------------------
    IF v_count > 0 THEN
        v_result := 0;
    ELSE
        v_result := 1;
    END IF;

    RETURN v_result;

EXCEPTION
    -- -----------------------------------------------------------------
    -- Defensive exception handler: in case of any unexpected runtime
    -- error (e.g. data type conversion, table access issues), we return
    -- 0 (invalid) so the form does not silently allow a save while the
    -- validation logic itself is failing. The caller / form framework
    -- is expected to surface this as a validation failure to the user.
    -- -----------------------------------------------------------------
    WHEN OTHERS THEN
        RETURN 0;
END validate_seq_unique;
/