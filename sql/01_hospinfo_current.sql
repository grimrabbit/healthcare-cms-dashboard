-- =====================================================================
-- 01_hospinfo_current.sql
-- Normalizes the current CMS Hospital General Information file so it
-- joins cleanly to Timely_and_Effective_Care_Hospital.
--
-- SETUP FIRST (DB Browser for SQLite):
--   File > Import > Table from CSV...
--   Select HospInfo__2026_.csv
--   Table name: HospInfo2026
--   Column names on first line: checked
--   Then run this script (Execute SQL tab), then run 00, then 02/03/04.
--
-- WHY THIS VIEW EXISTS:
--   "Facility ID" in Timely_and_Effective_Care_Hospital has INTEGER
--   affinity, so plain numeric IDs lose their leading zero at storage
--   time (e.g. "010001" -> 10001). 164 IDs in the new file end in "F"
--   (Rural Emergency Hospital conversions) and stay text with the
--   leading zero. This view reproduces that same per-row behavior so
--   both numeric and "F"-suffixed IDs join correctly.
-- Dataset: CMS Hospital General Information, data.cms.gov/provider-data/
--   dataset/xubh-q36u. Last Modified: 2026-07-22. Released: 2026-08-13.
-- =====================================================================

DROP VIEW IF EXISTS hospinfo_current;
CREATE VIEW hospinfo_current AS
SELECT
    CASE WHEN "Facility ID" GLOB '[0-9]*' AND "Facility ID" NOT GLOB '*[^0-9]*'
         THEN CAST("Facility ID" AS INTEGER)
         ELSE "Facility ID" END                AS facility_id,
    "Facility Name"                            AS facility_name,
    "State"                                    AS state,
    "Hospital Type"                            AS hospital_type,
    "Hospital Ownership"                       AS hospital_ownership,
    "Hospital overall rating"                  AS star_rating,
    CAST("Count of Facility READM Measures" AS INTEGER)  AS readm_measures_graded,
    CAST("Count of READM Measures Better" AS INTEGER)    AS readm_better,
    CAST("Count of READM Measures No Different" AS INTEGER) AS readm_no_different,
    CAST("Count of READM Measures Worse" AS INTEGER)     AS readm_worse
FROM HospInfo2026;
