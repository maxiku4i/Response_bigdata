-- Задание 8: Самый активный студент

-- Студент с максимальным количеством логов
SELECT 
    userid,
    COUNT(*) as total_logs,
    SUM(s_all) as total_events
FROM logs
GROUP BY userid
ORDER BY total_logs DESC
LIMIT 1;