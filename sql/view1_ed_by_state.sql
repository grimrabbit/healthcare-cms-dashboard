SELECT
    t."State",
    ROUND(AVG(CAST(t."Score" AS INTEGER)), 1) AS avg_ed_wait_minutes,
    COUNT(DISTINCT t."Facility ID")           AS hospital_count
FROM Timely_and_Effective_Care_Hospital t
WHERE
    t."Measure ID"  = 'OP_18b'
    AND t."Score"   != 'Not Available'
    AND CAST(t."Sample" AS INTEGER) >= 30
GROUP BY t."State"
ORDER BY avg_ed_wait_minutes DESC;