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
--   * facility_id is normalized (numeric IDs cast to integer, alphanumeric
--     IDs kept as text) so the join to hospinfo_current works whether the
--     CSV was imported with text or integer column types.
--   * HospInfo is NOT joined here. Joins happen in the views that need
--     hospital attributes, so the state view uses the same hospitals
--     as the scatter view, minus only the unmatched / unrated ones.
-- =====================================================================

DROP VIEW IF EXISTS ed_wait_valid;
CREATE VIEW ed_wait_valid AS
SELECT
    CASE WHEN t."Facility ID" GLOB '[0-9]*' AND t."Facility ID" NOT GLOB '*[^0-9]*'
         THEN CAST(t."Facility ID" AS INTEGER)
         ELSE t."Facility ID" END AS facility_id,   -- same normalization as 01_hospinfo_current.sql
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
    CASE WHEN t."Facility ID" GLOB '[0-9]*' AND t."Facility ID" NOT GLOB '*[^0-9]*'
         THEN CAST(t."Facility ID" AS INTEGER)
         ELSE t."Facility ID" END AS facility_id,   -- same normalization as 01_hospinfo_current.sql
    t."State"                    AS state,
    CAST(t."Score"  AS INTEGER)  AS sepsis_score,      -- SEP_1: % of cases receiving bundle-compliant care
    CAST(t."Sample" AS INTEGER)  AS patient_sample
FROM Timely_and_Effective_Care_Hospital t
WHERE t."Measure ID" = 'SEP_1'
  AND t."Score" GLOB '[0-9]*'
  AND CAST(t."Sample" AS INTEGER) >= 30;
