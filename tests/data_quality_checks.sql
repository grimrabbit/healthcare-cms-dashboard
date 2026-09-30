-- =====================================================================
-- data_quality_checks.sql
-- Run after 00_cohort_definitions.sql and 01_hospinfo_current.sql.
-- Returns one row per check. Every check should show failures = 0 and
-- status = 'PASS'. Any FAIL means a view's output can't be trusted until
-- the cause is found.
--
-- Same idea as dbt tests: each check counts the rows that break a rule.
-- The scorecard (View 6) is protected indirectly: it joins ed_wait_valid
-- to hospinfo_current, sepsis_valid and ed_volume, so if each of those has
-- one row per hospital (checks 1-4), the scorecard has one row per hospital.
-- =====================================================================

WITH checks AS (

    -- 1-4. One row per hospital in every building-block view
    SELECT 1 AS check_id, 'ed_wait_valid: one row per hospital' AS check_name,
           (SELECT COUNT(*) FROM (SELECT facility_id FROM ed_wait_valid
                                  GROUP BY facility_id HAVING COUNT(*) > 1)) AS failures
    UNION ALL
    SELECT 2, 'sepsis_valid: one row per hospital',
           (SELECT COUNT(*) FROM (SELECT facility_id FROM sepsis_valid
                                  GROUP BY facility_id HAVING COUNT(*) > 1))
    UNION ALL
    SELECT 3, 'hospinfo_current: one row per hospital',
           (SELECT COUNT(*) FROM (SELECT facility_id FROM hospinfo_current
                                  GROUP BY facility_id HAVING COUNT(*) > 1))
    UNION ALL
    SELECT 4, 'ed_volume: one row per hospital',
           (SELECT COUNT(*) FROM (SELECT facility_id FROM ed_volume
                                  GROUP BY facility_id HAVING COUNT(*) > 1))

    -- 5-6. Cohort rule actually applied (Sample >= 30)
    UNION ALL
    SELECT 5, 'ed_wait_valid: every score based on 30+ patients',
           (SELECT COUNT(*) FROM ed_wait_valid WHERE patient_sample < 30)
    UNION ALL
    SELECT 6, 'sepsis_valid: every score based on 30+ patients',
           (SELECT COUNT(*) FROM sepsis_valid WHERE patient_sample < 30)

    -- 7-8. Values in a plausible range
    UNION ALL
    SELECT 7, 'ED wait between 1 and 1,440 minutes (one day)',
           (SELECT COUNT(*) FROM ed_wait_valid
            WHERE ed_wait_minutes < 1 OR ed_wait_minutes > 1440)
    UNION ALL
    SELECT 8, 'Sepsis score between 0 and 100 percent',
           (SELECT COUNT(*) FROM sepsis_valid
            WHERE sepsis_score < 0 OR sepsis_score > 100)

    -- 9. Star rating is 1-5 or Not Available
    UNION ALL
    SELECT 9, 'Star rating is 1-5 or Not Available',
           (SELECT COUNT(*) FROM hospinfo_current
            WHERE star_rating NOT IN ('1', '2', '3', '4', '5', 'Not Available'))

    -- 10-11. Readmission counts add up (View 5 depends on these)
    UNION ALL
    SELECT 10, 'Readmission ratings: better + no different + worse = graded',
           (SELECT COUNT(*) FROM hospinfo_current
            WHERE readm_measures_graded > 0
              AND readm_better + readm_no_different + readm_worse <> readm_measures_graded)
    UNION ALL
    SELECT 11, 'Readmission ratings: worse never exceeds graded',
           (SELECT COUNT(*) FROM hospinfo_current
            WHERE readm_worse > readm_measures_graded)

    -- 12. Join coverage: ED hospitals missing from the hospital information file
    --     Expected: 9 (hospitals closed or deregistered since the reporting period).
    --     Fails if more than 1% of ED hospitals stop matching, which would signal
    --     an ID formatting problem like the leading-zero issue fixed earlier.
    UNION ALL
    SELECT 12, 'ED hospitals matched to hospital information file (>= 99%)',
           (SELECT CASE WHEN 1.0 * SUM(h.facility_id IS NULL) / COUNT(*) > 0.01
                        THEN SUM(h.facility_id IS NULL) ELSE 0 END
            FROM ed_wait_valid e
            LEFT JOIN hospinfo_current h ON e.facility_id = h.facility_id)

    -- 13. ED volume categories are only the four expected values
    UNION ALL
    SELECT 13, 'ED volume is low, medium, high or very high',
           (SELECT COUNT(*) FROM ed_volume
            WHERE ed_volume NOT IN ('low', 'medium', 'high', 'very high'))
)
SELECT
    check_id,
    check_name,
    failures,
    CASE WHEN failures = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM checks
ORDER BY check_id;
