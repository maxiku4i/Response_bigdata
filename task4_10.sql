-- Задание 10: Кафедры с отличниками и двоечниками

-- 1. Кафедра с наибольшим количеством отличников (оценка 5)
WITH excellent_students AS (
    SELECT 
        depart,
        COUNT(DISTINCT userid) as excellent_count
    FROM logs
    WHERE namer_level = '5'
    GROUP BY depart
)
SELECT 
    d.name as department_name,
    es.excellent_count
FROM excellent_students es
JOIN departments d ON es.depart = d.id
ORDER BY es.excellent_count DESC
LIMIT 1;

-- 2. Кафедра с наибольшим количеством двоечников (оценка 2)
WITH poor_students AS (
    SELECT 
        depart,
        COUNT(DISTINCT userid) as poor_count
    FROM logs
    WHERE namer_level = '2'
    GROUP BY depart
)
SELECT 
    d.name as department_name,
    ps.poor_count
FROM poor_students ps
JOIN departments d ON ps.depart = d.id
ORDER BY ps.poor_count DESC
LIMIT 1;