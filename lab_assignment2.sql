
SELECT 
    Gender,
    COUNT(*) AS StudentCount
FROM Student
GROUP BY Gender;