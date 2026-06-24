/*
project: repm
object_type: T
object_name: repm_action_point
event_type: followup_action
function_name: recompute_progress_rollup
form_no:
field_name:
business_logic: Recompute activity/task/phase/project % complete.
                Triggered on add, edit, mark_done, mark_blocked, cancel.
                Runs all four levels in a single transaction:
                  1. Activity pct = Done / non-CN action points * 100
                  2. Task pct     = avg of activity pct (activities have no weightage)
                  3. Phase pct    = weighted avg of task pct using task.weightage_pct
                  4. Project pct  = weighted avg of phase pct using phase.weightage_pct
*/
CREATE OR REPLACE FUNCTION recompute_progress_rollup(p jsonb) RETURNS jsonb AS $$
DECLARE
    v_activity_id TEXT := TRIM(p->>'ACTIVITY_ID');
    v_task_id     TEXT := TRIM(p->>'TASK_ID');
    v_phase_id    TEXT := TRIM(p->>'PHASE_ID');
    v_proj_code   TEXT := TRIM(p->>'PROJ_CODE');
    v_total       INTEGER;
    v_done        INTEGER;
    v_pct         NUMERIC(5,2);
BEGIN
    -- Step 1: Recompute activity pct_complete
    IF v_activity_id IS NOT NULL AND v_activity_id <> '' THEN
        SELECT COUNT(*) FILTER (WHERE status <> 'CN'),
               COUNT(*) FILTER (WHERE status = 'DN')
          INTO v_total, v_done
          FROM repm_action_point
         WHERE TRIM(activity_id) = v_activity_id;

        v_pct := CASE WHEN COALESCE(v_total, 0) = 0 THEN 0
                      ELSE ROUND((v_done::NUMERIC / v_total) * 100, 2)
                 END;

        UPDATE repm_activity
           SET pct_complete = v_pct,
               chg_date     = CURRENT_DATE,
               chg_user     = COALESCE(p->>'_logged_in_user', 'system')
         WHERE TRIM(activity_id) = v_activity_id;
    END IF;

    -- Step 2: Roll-up to Task
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

    -- Step 3: Roll-up to Phase (weighted by task.weightage_pct)
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

    -- Step 4: Roll-up to Project (weighted by phase.weightage_pct)
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
