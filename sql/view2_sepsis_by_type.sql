SELECT
    h."Hospital Type",
    ROUND(AVG(CAST(t."Score" AS INTEGER)), 1) AS avg_sepsis_score,
    COUNT(DISTINCT t."Facility ID")           AS hospital_count
FROM Timely_and_Effective_Care_Hospital t
INNER JOIN HospInfo h
    ON t."Facility ID" = h."Provider ID"
WHERE
    t."Measure ID"  = 'SEP_1'
    AND t."Score"   != 'Not Available'
    AND CAST(t."Sample" AS INTEGER) >= 20
GROUP BY h."Hospital Type"
ORDER BY avg_sepsis_score DESC;