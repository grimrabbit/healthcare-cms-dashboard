-- View 6: hospital network scorecard (one row per hospital)
-- Stakeholder: health plan network management (hypothetical). Puts ED access
-- and quality metrics side by side for contract review. No composite score:
-- weighting the metrics would require choices this data can't justify.
--
-- Requires: 00_cohort_definitions.sql, 01_hospinfo_current.sql
-- Base population: hospitals with a valid OP_18b score (ed_wait_valid) that
-- match the current Hospital General Information file.
-- Ranks and quartiles are computed across ALL valid ED hospitals in the state
-- (same population as View 4). Quartiles are left NULL in states with fewer
-- than 10 ranked hospitals, where they aren't meaningful.
-- Sepsis and readmission columns are NULL when a hospital isn't scored.

WITH ed_ranked AS (
    SELECT
        e.facility_id,
        e.ed_wait_minutes,
        RANK()  OVER (PARTITION BY e.state ORDER BY e.ed_wait_minutes) AS ed_wait_state_rank,
        NTILE(4) OVER (PARTITION BY e.state ORDER BY e.ed_wait_minutes) AS ed_wait_quartile_raw,
        COUNT(*) OVER (PARTITION BY e.state)                            AS hospitals_in_state
    FROM ed_wait_valid e
)
SELECT
    CASE WHEN typeof(h.facility_id) = 'integer'
         THEN printf('%06d', h.facility_id)
         ELSE h.facility_id END                     AS "Facility ID",  -- restore 6-character CCN
    h.facility_name                                 AS "Hospital Name",
    h.state                                         AS "State",
    h.hospital_type                                 AS "Hospital Type",
    h.hospital_ownership                            AS "Hospital Ownership",
    h.star_rating                                   AS star_rating,
    r.ed_wait_minutes                               AS ed_wait_minutes,
    r.ed_wait_state_rank                            AS ed_wait_state_rank,
    r.hospitals_in_state                            AS hospitals_in_state,
    CASE WHEN r.hospitals_in_state >= 10
         THEN r.ed_wait_quartile_raw END            AS ed_wait_state_quartile,  -- 1 = fastest quarter
    s.sepsis_score                                  AS sepsis_score,
    NULLIF(h.readm_measures_graded, 0)              AS readm_measures_graded,
    CASE WHEN h.readm_measures_graded > 0
         THEN h.readm_worse END                     AS readm_measures_worse,
    CASE WHEN h.readm_measures_graded > 0
         THEN ROUND(100.0 * h.readm_worse / h.readm_measures_graded, 1) END
                                                    AS pct_readm_measures_worse
FROM ed_ranked r
INNER JOIN hospinfo_current h
    ON r.facility_id = h.facility_id
LEFT JOIN sepsis_valid s
    ON r.facility_id = s.facility_id
ORDER BY h.state, r.ed_wait_state_rank;
