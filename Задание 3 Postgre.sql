-- 1.1. Список всех таблиц
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'bookings'
ORDER BY table_name;

-- 1.2. Структура каждой таблицы
SELECT count(*)
FROM information_schema.tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema','pg catalog')
    table_name,
    column_name,
    data_type,
    character_maximum_length as max_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'bookings'
ORDER BY table_name, ordinal_position;
-- 2.1. Типы столбцов и количество записей (отдельно)
-- Структура
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'bookings'
ORDER BY table_name, ordinal_position;

-- Количество записей
SELECT 
    relname as table_name,
    n_live_tup as row_count
FROM pg_stat_user_tables
WHERE schemaname = 'bookings'
ORDER BY n_live_tup DESC;

-- 2.2. Словарь таблица-количество записей
SELECT 
    relname as table_name,
    n_live_tup as record_count
INTO TEMP TABLE table_record_counts  -- создаем временную таблицу
FROM pg_stat_user_tables
WHERE schemaname = 'bookings';

SELECT * FROM table_record_counts ORDER BY record_count DESC;

-- 2.3. Таблица с максимальным количеством записей
SELECT 
    table_name,
    record_count as max_record_count
FROM table_record_counts
ORDER BY record_count DESC
LIMIT 1;
-- Задание 3: 
SELECT DISTINCT fare_conditions 
FROM bookings.seats 
ORDER BY fare_conditions;
-- ЗАДАНИЕ 4: Выручка по тарифам
-- Задание: По каждому тарифу найти общую сумму выручки за продажу билетов.

SELECT 
    fare_conditions as "Тариф",
    SUM(amount) as "Общая выручка",
    ROUND(SUM(amount), 2) as "Выручка (округлено)"
FROM bookings.ticket_flights
GROUP BY fare_conditions
ORDER BY SUM(amount) DESC;
-- ЗАДАНИЕ 5:
SELECT 
    fare_conditions as "Самый прибыльный тариф",
    SUM(amount) as "Максимальный доход"
FROM bookings.ticket_flights
GROUP BY fare_conditions
ORDER BY SUM(amount) DESC
LIMIT 1;
-- ЗАДАНИЕ 5.1:
-- Анализ Способа 1 (подзапрос)
EXPLAIN ANALYZE
SELECT 
    aircraft_code,
    model->>'ru' as model_name,
    range
FROM bookings.aircrafts_data
WHERE range = (
    SELECT MIN(range) 
    FROM bookings.aircrafts_data
);

-- Анализ Способа 2 (оконные функции)
EXPLAIN ANALYZE
WITH ranked_aircrafts AS (
    SELECT 
        aircraft_code,
        model,
        range,
        RANK() OVER (ORDER BY range) as rank_position
    FROM bookings.aircrafts_data
)
SELECT 
    aircraft_code,
    model->>'ru' as model_name,
    range
FROM ranked_aircrafts
WHERE rank_position = 1;
-- Задание 6: Максимальная длительность полета

-- Максимальная длительность
SELECT MAX(scheduled_arrival - scheduled_departure) as max_duration
FROM bookings.flights
WHERE status = 'Arrived';

-- Количество рейсов с максимальной длительностью
WITH max_duration AS (
    SELECT MAX(scheduled_arrival - scheduled_departure) as max_dur
    FROM bookings.flights
    WHERE status = 'Arrived'
)
SELECT COUNT(*) as flights_with_max_duration
FROM bookings.flights f, max_duration md
WHERE f.status = 'Arrived' 
  AND (f.scheduled_arrival - f.scheduled_departure) = md.max_dur;
-- Задание 7: Маршруты с максимальной длительностью полета
SELECT MAX(scheduled_arrival - scheduled_departure) as duration
SELECT DISTINCT
        departure_airport,
        arrival_airport,
        MAX(scheduled_arrival - scheduled_departure) as duration
    FROM bookings.flights
    WHERE status = 'Arrived' AND SELECT MAX(scheduled_arrival - scheduled_departure) as duration FROM bookings.flights

WITH max_duration_flights AS (
    SELECT DISTINCT
        departure_airport,
        arrival_airport,
        MAX(scheduled_arrival - scheduled_departure) as duration
    FROM bookings.flights
    WHERE status = 'Arrived'
    GROUP BY departure_airport, arrival_airport
    HAVING MAX(scheduled_arrival - scheduled_departure) = (
        SELECT MAX(scheduled_arrival - scheduled_departure)
        FROM bookings.flights
        WHERE status = 'Arrived'
    )
)
SELECT 
    mdf.duration,
    dep.airport_code as departure_code,
    dep.airport_name->>'ru' as departure_airport_name,
    dep.city->>'ru' as departure_city,
    arr.airport_code as arrival_code,
    arr.airport_name->>'ru' as arrival_airport_name,
SELECT COUNT(*) FROM bookings.flights WHERE departure_airport = ad.airport_code
    arr.city->>'ru' as arrival_city
FROM max_duration_flights mdf
JOIN bookings.airports_data dep ON mdf.departure_airport = dep.airport_code
JOIN bookings.airports_data arr ON mdf.arrival_airport = arr.airport_code
ORDER BY departure_airport_name, arrival_airport_name;
-- Задание 8: Аэропорт с максимальной нагрузкой
SELECT departure_airport, ((COUNT(*)), arrival_airport, ((COUNT(*))
FROM bookings.flights
GROUP BY departure_airport
SELECT arrival_airport, COUNT(*) as arivals_count
FROM bookings.flights
GROUP BY arrival_airport
WITH max_n as (
	SELECT arrival_airport as code FROM bookings.flights
	UNION ALL
	SELECT departure_airport as code FROM bookings.flights
)
SELECT 
	code,
	COUNT(*) as total_load
FROM max_n
GROUP BY code
ORDER BY total_load DESC
LIMIT 1;
-- Задание 9: Среднее количество мест по классам обслуживания
SELECT 
    fare_conditions,
    ROUND(AVG(seat_count), 2) as avg_seat_count
FROM (
    SELECT 
        aircraft_code,
        fare_conditions,
        COUNT(*) as seat_count
    FROM bookings.seats
    GROUP BY aircraft_code, fare_conditions
) as aircraft_seats
GROUP BY fare_conditions
ORDER BY fare_conditions;
-- Задание 10: Самый дорогой перелет
-- 1. Самый дорогой перелет
WITH flight_revenue AS (
    SELECT 
        f.flight_id,
        SUM(tf.amount) as final_amount,
        f.departure_airport,
        f.arrival_airport
    FROM bookings.flights f
    JOIN bookings.ticket_flights tf ON f.flight_id = tf.flight_id
    GROUP BY f.flight_id, f.departure_airport, f.arrival_airport
)
SELECT 
    fr.flight_id,
    fr.final_amount,
    dep.airport_name->>'ru' as departure_airport,
    dep.city->>'ru' as departure_city,
    arr.airport_name->>'ru' as arrival_airport,
    arr.city->>'ru' as arrival_city
FROM flight_revenue fr
JOIN bookings.airports_data dep ON fr.departure_airport = dep.airport_code
JOIN bookings.airports_data arr ON fr.arrival_airport = arr.airport_code
WHERE fr.final_amount = (SELECT MAX(final_amount) FROM flight_revenue);

-- 2. Количество рейсов с максимальной выручкой
WITH flight_revenue AS (
    SELECT flight_id, SUM(amount) as final_amount
    FROM bookings.ticket_flights
    GROUP BY flight_id
)
SELECT COUNT(*) as flights_with_max_revenue
FROM flight_revenue
WHERE final_amount = (SELECT MAX(final_amount) FROM flight_revenue);
-- Дополнительное задание: Анализ узких мест авиаперевозчика

-- 1. Самые частые задержки по аэропортам
SELECT 
    f.departure_airport,
    ad.airport_name->>'ru' as airport_name,
    COUNT(*) as total_flights,
    SUM(CASE WHEN f.actual_departure > f.scheduled_departure THEN 1 ELSE 0 END) as delayed_flights,
    ROUND(100.0 * SUM(CASE WHEN f.actual_departure > f.scheduled_departure THEN 1 ELSE 0 END) / COUNT(*), 1) as delay_percentage
FROM bookings.flights f
JOIN bookings.airports_data ad ON f.departure_airport = ad.airport_code
WHERE f.status IN ('Departed', 'Arrived')
  AND f.scheduled_departure IS NOT NULL
  AND f.actual_departure IS NOT NULL
GROUP BY f.departure_airport, ad.airport_name
HAVING COUNT(*) > 10
ORDER BY delay_percentage DESC
LIMIT 10;

-- 2. Самолеты с низкой загрузкой (по заполняемости мест)
SELECT 
    f.aircraft_code,
    ad.model->>'ru' as model,
    COUNT(DISTINCT f.flight_id) as total_flights,
    ROUND(AVG(tf.ticket_count * 100.0 / s.seat_count), 1) as avg_load_percentage
FROM bookings.flights f
JOIN bookings.aircrafts_data ad ON f.aircraft_code = ad.aircraft_code
JOIN (
    SELECT aircraft_code, COUNT(*) as seat_count
    FROM bookings.seats
    GROUP BY aircraft_code
) s ON f.aircraft_code = s.aircraft_code
JOIN (
    SELECT flight_id, COUNT(*) as ticket_count
    FROM bookings.ticket_flights
    GROUP BY flight_id
) tf ON f.flight_id = tf.flight_id
WHERE f.status IN ('Departed', 'Arrived')
GROUP BY f.aircraft_code, ad.model
HAVING COUNT(DISTINCT f.flight_id) >= 5
ORDER BY avg_load_percentage
LIMIT 10;

-- 3. Маршруты с наибольшим количеством отмен
SELECT 
    f.departure_airport,
    f.arrival_airport,
    dep.airport_name->>'ru' as departure_name,
    arr.airport_name->>'ru' as arrival_name,
    COUNT(*) as total_flights,
    SUM(CASE WHEN f.status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled_flights,
    ROUND(100.0 * SUM(CASE WHEN f.status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 1) as cancel_percentage
FROM bookings.flights f
JOIN bookings.airports_data dep ON f.departure_airport = dep.airport_code
JOIN bookings.airports_data arr ON f.arrival_airport = arr.airport_code
GROUP BY f.departure_airport, f.arrival_airport, dep.airport_name, arr.airport_name
HAVING COUNT(*) >= 5
ORDER BY cancel_percentage DESC, cancelled_flights DESC
LIMIT 10;