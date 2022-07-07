--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
select *,
row_number() over(order by payment_date) as number_payment,
row_number() over(partition by customer_id order by payment_date) as number_customer_payment,
sum(amount) over(partition by customer_id order by payment_date, amount) as sum_customer_payment,
dense_rank() over(partition by customer_id order by amount DESC) as rank_customer_amount
from public.payment
order by customer_id, amount;




--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
select customer_id, amount, 
lag (amount, 1, 0) over(partition by customer_id order by payment_date) as amount_befor
from public.payment;




--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select customer_id, amount, amount_after, amount_after - amount as delta_after
from
	(select customer_id, amount, 
	lead (amount, 1, 0) over(partition by customer_id order by payment_date) as amount_after
	from public.payment) q1;




--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select payment_id, customer_id, staff_id, rental_id, amount, last_payment
from
	(select *,
	first_value(payment_date) over(partition by customer_id order by payment_date DESC) as last_payment
	from public.payment) q1
where payment_date = last_payment
order by customer_id;




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.
select staff_id, payment_date, sum_day_amount
from
	(
	select staff_id, payment_date,
	sum(sum_amount) over(partition by staff_id order by payment_date) sum_day_amount
   	from
		(
		select staff_id, payment_date::date,
		sum(amount) over(partition by staff_id order by payment_date::date) sum_amount
		from
			(
			select *
			from public.payment
			where date_part('month', payment_date) = 8
			) q1
        )q2
    ) q3
group by 1, 2, 3



--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку
with cte_p AS (
select *
from public.payment
where payment_date::date = '2005-08-20'
order by payment_date), 
cte_p_num AS (
select *,
row_number() over(order by payment_date) as number
from cte_p)
select customer_id, first_name, last_name, email
from cte_p_num
join public.customer using(customer_id)
where number % 100 = 0;



--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм






