-- View 3: hospital star rating vs ED wait (OP_18b), one row per hospital
-- Cohort: ed_wait_valid (see 00_cohort_definitions.sql), joined to HospInfo.
-- Extra filter specific to this view: hospital must have a star rating.
SELECT
    h."Hospital Name"                         AS "Hospital Name",
    h."State"                                 AS "State",
    h."Hospital Type"                         AS "Hospital Type",
    h."Hospital overall rating"               AS star_rating,
    e.ed_wait_minutes                         AS ed_wait_minutes,
    e.patient_sample                          AS patient_sample
FROM ed_wait_valid e
INNER JOIN HospInfo h
    ON e.facility_id = h."Provider ID"
WHERE h."Hospital overall rating" != 'Not Available'
ORDER BY h."Hospital overall rating", e.ed_wait_minutes;
