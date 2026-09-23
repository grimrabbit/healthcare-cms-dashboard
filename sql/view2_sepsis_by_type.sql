-- View 2: average sepsis care score (SEP_1) by hospital type
-- Cohort: sepsis_valid (see 00_cohort_definitions.sql), joined to the
-- current Hospital General Information file (see 01_hospinfo_current.sql)
SELECT
    h.hospital_type                           AS "Hospital Type",
    ROUND(AVG(s.sepsis_score), 1)             AS avg_sepsis_score,
    COUNT(DISTINCT s.facility_id)             AS hospital_count
FROM sepsis_valid s
INNER JOIN hospinfo_current h
    ON s.facility_id = h.facility_id
GROUP BY h.hospital_type
ORDER BY avg_sepsis_score DESC;
