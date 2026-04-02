-- Задание 6: Курсы с несколькими кафедрами

-- 1. Проверяем, есть ли курсы с несколькими кафедрами
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT courseid
            FROM logs
            GROUP BY courseid
            HAVING COUNT(DISTINCT depart) > 1
        ) THEN 'Да, существуют курсы с несколькими кафедрами'
        ELSE 'Нет, у каждого курса только одна кафедра'
    END as answer;

-- 2. Количество таких курсов
SELECT 
    COUNT(*) as courses_with_multiple_departments
FROM (
    SELECT courseid
    FROM logs
    GROUP BY courseid
    HAVING COUNT(DISTINCT depart) > 1
) as multi_dept_courses;

-- 3. Конкретные курсы с несколькими кафедрами и названиями кафедр
WITH course_departments AS (
    SELECT 
        l.courseid,
        COUNT(DISTINCT l.depart) as department_count,
        STRING_AGG(DISTINCT d.name, ', ' ORDER BY d.name) as department_names,
        STRING_AGG(DISTINCT l.depart, ', ' ORDER BY l.depart) as department_ids
    FROM logs l
    JOIN departments d ON l.depart = d.id
    GROUP BY l.courseid
    HAVING COUNT(DISTINCT l.depart) > 1
)
SELECT 
    courseid,
    department_count,
    department_names,
    department_ids
FROM course_departments
ORDER BY department_count DESC, courseid;