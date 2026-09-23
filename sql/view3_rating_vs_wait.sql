SELECT
    h."Hospital Name",
    h."State",
    h."Hospital Type",
    h."Hospital overall rating"             AS star_rating,
    CAST(t."Score" AS INTEGER)              AS ed_wait_minutes,
    CAST(t."Sample" AS INTEGER)             AS patient_sample
FROM Timely_and_Effective_Care_Hospital t
INNER JOIN HospInfo h
    ON t."Facility ID" = h."Provider ID"
WHERE
    t."Measure ID"               = 'OP_18b'
    AND t."Score"                != 'Not Available'
    AND h."Hospital overall rating" != 'Not Available'
    AND CAST(t."Sample" AS INTEGER) BETWEEN 50 AND 5000
ORDER BY h."Hospital overall rating", ed_wait_minutes;