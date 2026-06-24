/*
project: repm
object_type: T
object_name: repm_action_point
event_type: form_validation
function_name: validate_seq_unique
form_no: 1
field_name: SEQ_NO
business_logic: Action Point Sequence Number must be unique within the same Activity
                (PROJ_CODE + PHASE_ID + TASK_ID + ACTIVITY_ID). Excludes the current
                record (ACTION_ID) so that re-saving an existing row does not flag itself.
                Returns 1 = valid, 0 = duplicate found.
*/
CREATE OR REPLACE FUNCTION validate_seq_unique(
    p_action_id     TEXT,   -- (1.ACTION_ID)    current record id; NULL for new rows
    p_proj_code     TEXT,   -- (1.PROJ_CODE)    project scope
    p_phase_id      TEXT,   -- (1.PHASE_ID)     phase scope
    p_task_id       TEXT,   -- (1.TASK_ID)      task scope
    p_activity_id   TEXT,   -- (1.ACTIVITY_ID)  activity scope
    p_seq_no        NUMERIC -- (1.SEQ_NO)       sequence number to validate
) RETURNS INTEGER AS $$
DECLARE
    v_result INTEGER := 1;
BEGIN
    -- Guard: if any scope key or seq_no is missing, skip the check (treat as valid)
    IF p_seq_no IS NULL OR p_proj_code IS NULL OR p_phase_id IS NULL
       OR p_task_id IS NULL OR p_activity_id IS NULL THEN
        RETURN 1;
    END IF;

    -- Check for another row in the same activity with the same SEQ_NO
    IF EXISTS (
        SELECT 1
          FROM repm_action_point ap
         WHERE ap.proj_code   = p_proj_code
           AND ap.phase_id    = p_phase_id
           AND ap.task_id     = p_task_id
           AND ap.activity_id = p_activity_id
           AND ap.seq_no      = p_seq_no
           AND COALESCE(ap.action_id, '~') <> COALESCE(p_action_id, '~')
         LIMIT 1
    ) THEN
        v_result := 0;
    END IF;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$ LANGUAGE plpgsql;
