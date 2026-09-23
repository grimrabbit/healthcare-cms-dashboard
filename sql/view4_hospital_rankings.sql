-- View 4: in-state hospital ranking by ED wait (OP_18b)
-- Cohort: ed_wait_valid (see 00_cohort_definitions.sql) -- same 4,073 hospitals as View 1.
-- No HospInfo join, so hospitals missing from HospInfo are still ranked.
-- state_rank 1 = shortest median wait in the state. Ties share a rank (RANK, not ROW_NUMBER).
SELECT
    e.state                                                             AS "State",
    e.facility_id                                                       AS "Facility ID",
    e.facility_name                                                     AS "Facility Name",
    e.ed_wait_minutes                                                   AS ed_wait_minutes,
    e.patient_sample                                                    AS patient_sample,
    RANK() OVER (PARTITION BY e.state ORDER BY e.ed_wait_minutes ASC)   AS state_rank,
    COUNT(*) OVER (PARTITION BY e.state)                                AS hospitals_in_state,
    ROUND(AVG(e.ed_wait_minutes) OVER (PARTITION BY e.state), 1)        AS state_avg_wait,
    ROUND(e.ed_wait_minutes - AVG(e.ed_wait_minutes) OVER (PARTITION BY e.state), 1)
                                                                        AS minutes_vs_state_avg
FROM ed_wait_valid e
ORDER BY e.state, state_rank, e.facility_name;
