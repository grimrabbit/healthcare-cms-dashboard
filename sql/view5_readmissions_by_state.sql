-- View 5: readmission performance by state, measure-level rate (HRRP-relevant)
-- Source: hospinfo_current (see 01_hospinfo_current.sql).
-- Cohort: hospitals with at least one graded readmission measure
-- (readm_measures_graded > 0). Only Acute Care, Critical Access, and
-- Acute Care - VA hospitals are graded on readmissions.
--
-- Metric: pct_measures_worse = worse measures / graded measures, summed
-- across every hospital in the state.
--
-- Why measure-level and not hospital-level: an earlier version flagged a
-- hospital "worse" if ANY of its graded measures was worse. That rewards
-- hospitals graded on fewer measures: hospitals graded on 1 measure were
-- flagged 0.6% of the time, hospitals graded on 11 measures 77.8% of the
-- time. Critical Access Hospitals average 3.2 graded measures vs. 7.4 for
-- Acute Care, so rural states looked better partly by construction.
-- Counting measures instead of hospitals removes that effect.

DROP VIEW IF EXISTS readm_valid;
CREATE VIEW readm_valid AS
SELECT
    h.facility_id,
    h.state,
    h.hospital_type,
    h.readm_measures_graded,
    h.readm_better,
    h.readm_no_different,
    h.readm_worse
FROM hospinfo_current h
WHERE h.readm_measures_graded > 0;

SELECT
    r.state                                                         AS "State",
    COUNT(*)                                                        AS hospitals_graded,
    SUM(r.readm_measures_graded)                                    AS measures_graded,
    SUM(r.readm_worse)                                              AS measures_worse,
    SUM(r.readm_better)                                             AS measures_better,
    ROUND(100.0 * SUM(r.readm_worse)  / SUM(r.readm_measures_graded), 1) AS pct_measures_worse,
    ROUND(100.0 * SUM(r.readm_better) / SUM(r.readm_measures_graded), 1) AS pct_measures_better
FROM readm_valid r
GROUP BY r.state
ORDER BY pct_measures_worse DESC;
