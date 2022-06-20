--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
SELECT customer_id, first_name, last_name, address, city, country
FROM 
	customer 
	JOIN address USING (address_id)
	JOIN city USING (city_id)
	JOIN country USING (country_id)
ORDER BY 1;





--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
SELECT store_id, COUNT(customer_id) "Покупателей"  
FROM 
	store
	JOIN customer USING (store_id)
GROUP BY store_id
ORDER BY store_id;





--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
SELECT store_id, COUNT(customer_id) "Покупателей"  
FROM 
	store
	JOIN	customer USING (store_id)
GROUP BY	store_id
HAVING COUNT(customer_id) >300
ORDER BY store_id;





-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
SELECT s.store_id, s.c "Покупателей", city "Город",
	   staff.first_name "Имя менеджера", staff.last_name "Фамилия менеджера"
FROM
	(SELECT store_id, COUNT(customer_id) c, store.address_id a, store.manager_staff_id m
	 FROM store
	 JOIN	customer USING (store_id)
	 GROUP BY	store_id
	 HAVING COUNT(customer_id) >300
	 ) s
JOIN staff ON s.m = staff.staff_id
JOIN address ON address.address_id = s.a
JOIN city USING (city_id);





--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
SELECT customer_id, first_name, last_name, count(*) "Количество аренд"
FROM customer 
JOIN rental USING (customer_id)
GROUP BY customer_id 
ORDER BY count(*)
DESC LIMIT 5;





--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
SELECT customer.customer_id, count(*) "Количество фильмов",
sum(amount) "Общая сумма", min(amount) "Минимальный платеж", max(amount) "Максимальный платеж"
FROM customer
JOIN rental ON customer.customer_id  = rental.customer_id 
JOIN payment USING (rental_id)
GROUP BY customer.customer_id 
ORDER BY 3 DESC;





--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
SELECT DISTINCT city.city, c.city
FROM city
CROSS JOIN (SELECT city FROM city) c
WHERE city.city != c.city;
 




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
SELECT customer_id, first_name||' ' ||last_name ФИО,
round(AVG(date(return_date) - date(rental_date)), 2) "Средняя продолжительность, дней"
FROM customer
JOIN rental USING (customer_id)
GROUP BY customer_id
ORDER BY ФИО; 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
SELECT film_id, count(*) Количество, round(sum(amount), 1) Сумма
FROM film
	JOIN inventory USING (film_id)
	JOIN rental USING (inventory_id)
	JOIN payment USING (rental_id)
GROUP BY film_id
ORDER BY 3 DESC;




--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
SELECT film_id, title
FROM film
	LEFT JOIN inventory USING (film_id)
	LEFT JOIN rental USING (inventory_id)
WHERE rental_id IS NULL
ORDER BY 1;




--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
SELECT staff.staff_id, count(*),
	CASE 
		WHEN count(*) > 7301 THEN 'Да'
		ELSE 'Нет'
	END "Премия"
FROM staff
	JOIN store ON staff.staff_id = store.manager_staff_id 
	JOIN customer ON store.store_id = customer.store_id 
	JOIN payment USING (customer_id)
GROUP BY 1;







