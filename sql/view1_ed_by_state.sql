-- View 1: average ED wait (OP_18b) by state
-- Cohort: ed_wait_valid (see 00_cohort_definitions.sql)
SELECT
    e.state                                   AS "State",
    ROUND(AVG(e.ed_wait_minutes), 1)          AS avg_ed_wait_minutes,
    COUNT(DISTINCT e.facility_id)             AS hospital_count
FROM ed_wait_valid e
GROUP BY e.state
ORDER BY avg_ed_wait_minutes DESC;
