-- ============================================
-- ЗАДАНИЕ 1: Замена запятых на точки
-- ============================================
SELECT 'ЗАДАНИЕ 1: Замена запятых на точки' as section;

UPDATE education_logs 
SET 
    s_all_avg = REPLACE(s_all_avg, ',', '.'),
    s_course_viewed_avg = REPLACE(s_course_viewed_avg, ',', '.'),
    s_q_attempt_viewed_avg = REPLACE(s_q_attempt_viewed_avg, ',', '.'),
    s_a_course_module_viewed_avg = REPLACE(s_a_course_module_viewed_avg, ',', '.'),
    s_a_submission_status_viewed_avg = REPLACE(s_a_submission_status_viewed_avg, ',', '.');

SELECT 'Первые 10 записей после обработки:' as result;
SELECT courseid, userid, num_week, s_all_avg, s_course_viewed_avg
FROM education_logs 
LIMIT 10;

-- ============================================
-- ЗАДАНИЕ 2: Количество кафедр
-- ============================================
SELECT 'ЗАДАНИЕ 2: Количество кафедр' as section;
SELECT COUNT(DISTINCT Depart) as total_departments
FROM education_logs;

-- ЗАДАНИЕ 3: Все кафедры с количеством курсов
SELECT 
    Depart,
    COUNT(DISTINCT courseid) as course_count
FROM education_logs
GROUP BY Depart
ORDER BY COUNT(DISTINCT courseid) DESC;

-- Кафедра с максимальным количеством курсов
SELECT 
    Depart,
    COUNT(DISTINCT courseid) as max_course_count
FROM education_logs
GROUP BY Depart
ORDER BY COUNT(DISTINCT courseid) DESC
LIMIT 1;
-- ЗАДАНИЕ 4:
-- Создание таблицы справочника кафедр
CREATE TABLE departments (
    id varchar(5) PRIMARY KEY,
    name varchar(50)
);

-- Вставка данных кафедр
INSERT INTO departments (id, name) VALUES
('1', 'Аиий'),
('2', 'Асу'),
('3', 'Аэпим'),
('4', 'Бийит'),
('5', 'Ви'),
('6', 'Втип'),
('7', 'Гмиопи'),
('8', 'Гмитк'),
('9', 'Гмууп'),
('10', 'Дизайна'),
('11', 'Дисо'),
('12', 'Иийб'),
('13', 'Итм'),
('14', 'Лип'),
('15', 'Лиутс'),
('16', 'Лим'),
('17', 'Менеджм.'),
('18', 'Митомидм'),
('19', 'Михт'),
('20', 'Писз'),
('21', 'Пиэммо'),
('22', 'Пмии'),
('23', 'Пойд'),
('24', 'Психол.'),
('25', 'Пэйдж'),
('26', 'Рмпи'),
('27', 'Ряояимк'),
('28', 'Сриппо'),
('29', 'СС'),
('30', 'Тиэс'),
('31', 'Том'),
('32', 'Тсса'),
('33', 'Уиис'),
('34', 'Усиба'),
('35', 'Физики'),
('36', 'Физкульт.'),
('37', 'Химия'),
('38', 'Хом'),
('39', 'Цдом'),
('40', 'Эимэ'),
('41', 'Эконом.'),
('42', 'Эпп'),
('43', 'Яил');

-- Проверка создания таблицы
SELECT * FROM departments ORDER BY id;
-- Задание 5: Вывести названия кафедр и количество курсов
SELECT 
    d.name as department_name,
    COUNT(DISTINCT e.courseid) as course_count
FROM education_logs e
JOIN departments d ON e.Depart = d.id
GROUP BY d.name, d.id
ORDER BY course_count DESC;
-- Задание 6: Курсы с несколькими кафедрами

-- 1. Проверяем, есть ли курсы с несколькими кафедрами
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT courseid
            FROM education_logs
            GROUP BY courseid
            HAVING COUNT(DISTINCT Depart) > 1
        ) THEN 'Да, существуют курсы с несколькими кафедрами'
        ELSE 'Нет, у каждого курса только одна кафедра'
    END as answer;

-- 2. Количество таких курсов
SELECT 
    COUNT(*) as courses_with_multiple_departments
FROM (
    SELECT courseid
    FROM education_logs
    GROUP BY courseid
    HAVING COUNT(DISTINCT Depart) > 1
) as multi_dept_courses;

-- 3. Названия кафедр, которые совместно преподают курсы
WITH multi_dept_courses AS (
    SELECT courseid
    FROM education_logs
    GROUP BY courseid
    HAVING COUNT(DISTINCT Depart) > 1
)
SELECT DISTINCT
    m.courseid,
    d.name as department_name
FROM multi_dept_courses m
JOIN education_logs l ON m.courseid = l.courseid
JOIN departments d ON l.Depart = d.id
ORDER BY m.courseid, d.name;
-- Задание 7: Количество студентов по оценкам

SELECT 
    NameR_Level as namer_level,
    COUNT(DISTINCT userid) as count
FROM education_logs
WHERE NameR_Level IN ('2', '3', '4', '5')
GROUP BY NameR_Level
ORDER BY NameR_Level;
-- Задание 8: Самый активный студент

-- Студент с максимальным количеством логов
SELECT 
    userid,
    COUNT(*) as total_logs
FROM education_logs
GROUP BY userid
ORDER BY COUNT(*) DESC
LIMIT 1;

-- С дополнительной информацией
SELECT 
    userid,
    COUNT(*) as total_logs,
    SUM(s_all) as total_events,
    AVG(s_all::numeric) as avg_events_per_week
FROM education_logs
GROUP BY userid
ORDER BY total_logs DESC
LIMIT 1;
-- Задание 9: Среднее количество событий по неделям

SELECT 
    num_week,
    AVG(s_all) as avg_events_per_week
FROM education_logs
GROUP BY num_week
ORDER BY num_week;
-- Задание 10: Кафедры с отличниками и двоечниками

-- 1. Кафедра с наибольшим количеством отличников (оценка 5)
SELECT 
    d.name as department_name,
    COUNT(DISTINCT l.userid) as excellent_students
FROM education_logs l
JOIN departments d ON l.Depart = d.id
WHERE l.NameR_Level = '5'
GROUP BY d.name, d.id
ORDER BY excellent_students DESC
LIMIT 1;

-- 2. Кафедра с наибольшим количеством двоечников (оценка 2)
SELECT 
    d.name as department_name,
    COUNT(DISTINCT l.userid) as poor_students
FROM education_logs l
JOIN departments d ON l.Depart = d.id
WHERE l.NameR_Level = '2'
GROUP BY d.name, d.id
ORDER BY poor_students DESC
LIMIT 1;