/*
project: repm
object_type: T
object_name: repm_action_point
event_type: cross_update
function_name: rollup_task_phase_project
form_no:
field_name:
business_logic: Roll-up % complete to task, phase and project using weightages.
                Task: simple avg of activity pct_complete (activities have no weightage).
                Phase: weighted avg of task pct_complete using task.weightage_pct.
                Project: weighted avg of phase pct_complete using phase.weightage_pct.
*/
CREATE OR REPLACE FUNCTION rollup_task_phase_project(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_task_id   TEXT := TRIM(p->>'TASK_ID');
    v_phase_id  TEXT := TRIM(p->>'PHASE_ID');
    v_proj_code TEXT := TRIM(p->>'PROJ_CODE');
    v_pct       NUMERIC(5,2);
BEGIN
    -- Roll-up to Task: simple avg of non-cancelled activity pct_complete
    IF v_task_id IS NOT NULL AND v_task_id <> '' THEN
        SELECT COALESCE(AVG(pct_complete), 0)
          INTO v_pct
          FROM repm_activity
         WHERE TRIM(task_id) = v_task_id
           AND status <> 'CN';

        UPDATE repm_task
           SET pct_complete = ROUND(v_pct, 2),
               chg_date     = CURRENT_DATE,
               chg_user     = COALESCE(p->>'_logged_in_user', 'system')
         WHERE TRIM(task_id) = v_task_id;
    END IF;

    -- Roll-up to Phase: weighted avg of non-cancelled task pct_complete
    IF v_phase_id IS NOT NULL AND v_phase_id <> '' THEN
        SELECT CASE
                   WHEN SUM(weightage_pct) IS NULL OR SUM(weightage_pct) = 0
                   THEN COALESCE(AVG(pct_complete), 0)
                   ELSE SUM(COALESCE(pct_complete, 0) * COALESCE(weightage_pct, 0))
                        / NULLIF(SUM(weightage_pct), 0)
               END
          INTO v_pct
          FROM repm_task
         WHERE TRIM(phase_id) = v_phase_id
           AND status <> 'CN';

        UPDATE repm_phase
           SET pct_complete = ROUND(COALESCE(v_pct, 0), 2),
               chg_date     = CURRENT_DATE,
               chg_user     = COALESCE(p->>'_logged_in_user', 'system')
         WHERE TRIM(phase_id) = v_phase_id;
    END IF;

    -- Roll-up to Project: weighted avg of non-cancelled phase pct_complete
    IF v_proj_code IS NOT NULL AND v_proj_code <> '' THEN
        SELECT CASE
                   WHEN SUM(weightage_pct) IS NULL OR SUM(weightage_pct) = 0
                   THEN COALESCE(AVG(pct_complete), 0)
                   ELSE SUM(COALESCE(pct_complete, 0) * COALESCE(weightage_pct, 0))
                        / NULLIF(SUM(weightage_pct), 0)
               END
          INTO v_pct
          FROM repm_phase
         WHERE TRIM(proj_code) = v_proj_code
           AND status <> 'CN';

        UPDATE repm_project
           SET pct_complete = ROUND(COALESCE(v_pct, 0), 2),
               chg_date     = CURRENT_DATE,
               chg_user     = COALESCE(p->>'_logged_in_user', 'system')
         WHERE TRIM(proj_code) = v_proj_code;
    END IF;

    RETURN '{}'::jsonb;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql;
