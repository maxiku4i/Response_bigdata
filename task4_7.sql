-- Задание 7: С выводом в нужном формате

SELECT 'Количество студентов по оценкам:' as title;

SELECT 
    namer_level,
    COUNT(DISTINCT userid) as count
FROM logs
WHERE namer_level IN ('2', '3', '4', '5')
GROUP BY namer_level
ORDER BY namer_level::integer;