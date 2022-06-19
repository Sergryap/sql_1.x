--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.
SELECT DISTINCT city
FROM city
ORDER BY city;





--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
SELECT DISTINCT city
FROM city
WHERE city iLIKE 'L%a' AND city NOT iLIKE '% %'
ORDER BY city;





--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.
SELECT * FROM payment
WHERE payment_date BETWEEN '17/06/2005'::date AND '19/06/2005'::date
AND amount <= 1
ORDER BY payment_date;





--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
SELECT * FROM payment
ORDER BY payment_date DESC
LIMIT 10;





--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.
SELECT CONCAT(first_name, ' ', last_name) "Фамили и имя", email "Электронная почта",
CHARACTER_LENGTH(email) "Длина email", last_update "Дата обновления"
FROM customer;





--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.
SELECT customer_id, store_id, LOWER(first_name) irst_name, LOWER(last_name) last_name, email,
address_id, activebool, create_date, last_update, active
FROM customer
WHERE active = 1 AND first_name IN('KELLY', 'WILLIE');





--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.
SELECT * FROM film
WHERE (rating = 'R' AND rental_rate BETWEEN 0 AND 3)
OR (rating = 'PG-13' AND rental_rate >= 4);





--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.
SELECT * FROM film
WHERE CHARACTER_LENGTH(description) IN (
	SELECT CHARACTER_LENGTH(description) lenght FROM film
	ORDER BY lenght DESC
	LIMIT 3)
ORDER BY title;





--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.
SELECT split_part(email, '@', 1) "До @", split_part(email, '@', 2) "После @"
FROM customer;





--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.

SELECT upper(substring(split_part(email, '@', 1), '(^.)'))||
	   OVERLAY(split_part(email, '@', 1) placing
	   lower(SUBSTRING(split_part(email, '@', 1) from 2 for CHARACTER_LENGTH(split_part(email, '@', 1))))
	   from 1 for CHARACTER_LENGTH(split_part(email, '@', 1))
	   ) "До @",
	   upper(substring(split_part(email, '@', 2), '(^.)'))||
	   OVERLAY(split_part(email, '@', 1) placing
	   lower(SUBSTRING(split_part(email, '@', 2) from 2 for CHARACTER_LENGTH(split_part(email, '@', 2))))
	   from 1 for CHARACTER_LENGTH(split_part(email, '@', 2))
	   ) "После @"
FROM customer;




