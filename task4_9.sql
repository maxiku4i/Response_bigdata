-- Задание 9: Среднее количество событий по неделям

SELECT 
    num_week,
    ROUND(AVG(s_all::numeric), 2) as avg_events_per_week
FROM logs
GROUP BY num_week
ORDER BY num_week;