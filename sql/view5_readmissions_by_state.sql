-- View 5: readmission performance by state (HRRP-relevant)
-- Cohort: hospitals with at least one graded READM measure
-- (readm_measures_graded > 0). Excludes hospital types CMS doesn't
-- grade on readmissions: Psychiatric, Childrens, Rural Emergency,
-- Acute Care - DoD, Long-term. Acute Care, Critical Access, and
-- Acute Care - VA are the only types graded (see 01_hospinfo_current.sql).
--
-- Classification (CASE WHEN) per hospital, based on its own measures
-- vs. the national average, mirrors the old file's single "above/at/
-- below average" column but is computed from the underlying counts:
--   'Worse than national average'  -> 1+ measure rated Worse
--   'Better than national average' -> 0 Worse, 1+ measure rated Better
--   'No different from average'    -> every graded measure No Different
--
-- State rate: hospitals rated Worse / hospitals graded (not measures),
-- so a state isn't skewed by one hospital reporting more measures than
-- another.

DROP VIEW IF EXISTS readm_valid;
CREATE VIEW readm_valid AS
SELECT
    h.facility_id,
    h.state,
    h.hospital_type,
    h.readm_measures_graded,
    h.readm_worse,
    h.readm_better,
    h.readm_no_different,
    CASE
        WHEN h.readm_worse > 0                          THEN 'Worse than national average'
        WHEN h.readm_worse = 0 AND h.readm_better > 0   THEN 'Better than national average'
        ELSE 'No different from national average'
    END                                                  AS readm_classification
FROM hospinfo_current h
WHERE h.readm_measures_graded > 0;

SELECT
    r.state                                             AS "State",
    COUNT(*)                                            AS hospitals_graded,
    SUM(r.readm_classification = 'Worse than national average')             AS n_worse,
    SUM(r.readm_classification = 'Better than national average')            AS n_better,
    SUM(r.readm_classification = 'No different from national average')      AS n_no_different,
    ROUND(100.0 * SUM(r.readm_classification = 'Worse than national average') / COUNT(*), 1)
                                                         AS pct_worse,
    ROUND(100.0 * SUM(r.readm_classification = 'Better than national average') / COUNT(*), 1)
                                                         AS pct_better
FROM readm_valid r
GROUP BY r.state
ORDER BY pct_worse DESC;
