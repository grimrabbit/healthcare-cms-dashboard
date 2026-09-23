-- View 3: hospital star rating vs ED wait (OP_18b), one row per hospital
-- Cohort: ed_wait_valid (see 00_cohort_definitions.sql), joined to the
-- current Hospital General Information file (see 01_hospinfo_current.sql).
-- Extra filter specific to this view: hospital must have a star rating.
SELECT
    h.facility_name                           AS "Hospital Name",
    h.state                                   AS "State",
    h.hospital_type                           AS "Hospital Type",
    h.star_rating                             AS star_rating,
    e.ed_wait_minutes                         AS ed_wait_minutes,
    e.patient_sample                          AS patient_sample
FROM ed_wait_valid e
INNER JOIN hospinfo_current h
    ON e.facility_id = h.facility_id
WHERE h.star_rating != 'Not Available'
ORDER BY h.star_rating, e.ed_wait_minutes;
