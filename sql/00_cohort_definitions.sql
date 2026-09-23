-- =====================================================================
-- 00_cohort_definitions.sql
-- Single source of truth for which hospital-measure rows count as "valid".
-- Run once in DB Browser for SQLite before views 1-3 (re-runnable).
--
-- Rule (applies to every measure): Score is numeric AND Sample >= 30.
--   * "Not Available" scores are excluded (CMS suppressed / no data).
--   * Sample >= 30 is the minimum patient count for a hospital's score
--     to be treated as a stable estimate. One rule, all measures.
--   * NO upper cap on Sample. Large samples are real hospitals, not
--     errors (see README metric definitions).
--   * HospInfo is NOT joined here. Joins happen in the views that need
--     hospital attributes, so the state view uses the same hospitals
--     as the scatter view, minus only the unmatched / unrated ones.
-- =====================================================================

DROP VIEW IF EXISTS ed_wait_valid;
CREATE VIEW ed_wait_valid AS
SELECT
    t."Facility ID"              AS facility_id,
    t."Facility Name"            AS facility_name,
    t."State"                    AS state,
    CAST(t."Score"  AS INTEGER)  AS ed_wait_minutes,   -- OP_18b: median minutes, arrival to departure
    CAST(t."Sample" AS INTEGER)  AS patient_sample
FROM Timely_and_Effective_Care_Hospital t
WHERE t."Measure ID" = 'OP_18b'
  AND t."Score" GLOB '[0-9]*'
  AND CAST(t."Sample" AS INTEGER) >= 30;

DROP VIEW IF EXISTS sepsis_valid;
CREATE VIEW sepsis_valid AS
SELECT
    t."Facility ID"              AS facility_id,
    t."State"                    AS state,
    CAST(t."Score"  AS INTEGER)  AS sepsis_score,      -- SEP_1: % of cases receiving bundle-compliant care
    CAST(t."Sample" AS INTEGER)  AS patient_sample
FROM Timely_and_Effective_Care_Hospital t
WHERE t."Measure ID" = 'SEP_1'
  AND t."Score" GLOB '[0-9]*'
  AND CAST(t."Sample" AS INTEGER) >= 30;
