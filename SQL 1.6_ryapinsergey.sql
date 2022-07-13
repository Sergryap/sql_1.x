--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

--explain analyze 67.5, time 0.86
SELECT *
FROM public.film
WHERE array['Behind the Scenes'] <@ special_features;




--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

--explain analyze 67.5, time 0.65
SELECT *
FROM public.film
WHERE special_features @> array['Behind the Scenes'];

--explain analyze 67.5, time 0,74
SELECT *
FROM public.film
WHERE special_features && array['Behind the Scenes'] = True;




--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

--explain analyze 720.7, time 30
WITH cte_film AS (
SELECT *
FROM public.film
WHERE special_features && array['Behind the Scenes'] = True)
SELECT customer_id, first_name, last_name, count(*), 'Behind the Scenes' special_futures
FROM public.rental
JOIN public.customer USING (customer_id)
JOIN public.inventory USING (inventory_id)
JOIN cte_film USING (film_id)
GROUP BY customer_id
ORDER BY 1;





--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

--explain analyze 720.7, time 35
SELECT customer_id, first_name, last_name, count(*), 'Behind the Scenes' special_futures
FROM public.rental
  JOIN public.customer USING (customer_id)
  JOIN public.inventory USING (inventory_id)
  JOIN (
             SELECT *
             FROM public.film
             WHERE special_features &&
             array['Behind the Scenes'] = True
            ) q USING (film_id)
GROUP BY customer_id
ORDER BY 1;





--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

--explain analyze 720.7
CREATE MATERIALIZED VIEW mat_view_1 AS
SELECT customer_id, first_name, last_name, count(*), 'Behind the Scenes' special_futures
FROM public.rental
  JOIN public.customer USING (customer_id)
  JOIN public.inventory USING (inventory_id)
  JOIN (
             SELECT *
             FROM public.film
             WHERE special_features &&
             array['Behind the Scenes'] = True
            ) q USING (film_id)
GROUP BY customer_id
ORDER BY 1;

REFRESH MATERIALIZED VIEW mat_view_1;





--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
Получилось везде примерно одно значение времени, стоимости равные
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
Примерно одинаково





--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
WITH start_payment AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY staff_id ORDER BY payment_date) AS first_payment
FROM public.payment)
SELECT payment_id, customer_id, staff_id, rental_id, amount, payment_date
FROM start_payment
WHERE first_payment = 1;





--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день
WITH c_rental_day AS (
SELECT rental_date::date, store_id, count(*) n
FROM public.rental
JOIN public.staff USING (staff_id)
GROUP BY rental_date::date, store_id),
c_rental_count_max AS (
SELECT rental_date, store_id, n, 
MAX(n) OVER(PARTITION BY store_id) AS n_max
FROM c_rental_day), 
c_pay_day AS (
SELECT payment_date::date, store_id, SUM(amount) p
FROM public.payment
JOIN public.staff USING (staff_id)
GROUP BY payment_date::date, store_id),
c_min_pay_day AS (
SELECT payment_date, store_id, p,
MIN(p) OVER(PARTITION BY store_id) AS p_min
FROM c_pay_day)
SELECT *
FROM
(SELECT store_id, payment_date "min payment date", p "min payment"
FROM c_min_pay_day
WHERE p = p_min) q1
JOIN
(SELECT store_id, rental_date "max rental date", n "max count rental"
FROM c_rental_count_max
WHERE n = n_max) q2
USING (store_id)
ORDER BY store_id




