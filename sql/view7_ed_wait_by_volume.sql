-- View 7: ED wait by ED volume category, compared with each hospital's state average
-- Requires: 00_cohort_definitions.sql
-- Population: hospitals with a valid OP_18b score (ed_wait_valid) and a reported
-- EDV category. State averages use ALL valid ED hospitals in the state (same as
-- View 1), so a hospital's gap is measured against the full state picture.
-- minutes_vs_state_avg < 0 means faster than the state average.

WITH ed_with_state AS (
    SELECT
        e.facility_id,
        e.state,
        e.ed_wait_minutes,
        e.ed_wait_minutes - AVG(e.ed_wait_minutes) OVER (PARTITION BY e.state) AS minutes_vs_state_avg
    FROM ed_wait_valid e
)
SELECT
    v.ed_volume                                 AS ed_volume,
    COUNT(*)                                    AS hospital_count,
    ROUND(AVG(w.ed_wait_minutes), 1)            AS avg_ed_wait_minutes,
    ROUND(AVG(w.minutes_vs_state_avg), 1)       AS avg_minutes_vs_state_avg
FROM ed_with_state w
INNER JOIN ed_volume v
    ON w.facility_id = v.facility_id
GROUP BY v.ed_volume, v.ed_volume_order
ORDER BY v.ed_volume_order;
