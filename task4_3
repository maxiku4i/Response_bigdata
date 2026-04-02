-- Задание 5: Курсы по названиям кафедр

-- Кафедры с количеством курсов (с названиями)
SELECT 
    d.name as department_name,
    COUNT(DISTINCT l.courseid) as course_count
FROM logs l
JOIN departments d ON l.depart = d.id
GROUP BY d.name, d.id
ORDER BY course_count DESC;

-- Кафедра с максимальным количеством курсов
SELECT 
    d.name as department_name,
    COUNT(DISTINCT l.courseid) as max_course_count
FROM logs l
JOIN departments d ON l.depart = d.id
GROUP BY d.name, d.id
ORDER BY COUNT(DISTINCT l.courseid) DESC
LIMIT 1;