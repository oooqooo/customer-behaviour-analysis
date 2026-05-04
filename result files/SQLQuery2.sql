--Find total revenue
select sum(sales) from man
--Find total number of orders
select count(order_id) from man
--Find total number of customers
select count(customer_id)from(select customer_id from man
group by customer_id)as d
--Find average order value
select avg(sales) from man

--Revenue by product category
select product_category ,sum(sales)
from man
group by product_category
--Revenue by region
select region ,sum(sales)
from man
group by region

--Monthly sales trend
--(Hint: use YEAR() and MONTH())
with raj as (select year ,sum(sales) total from man
group by year)
,ma as (
select year,month,sum(sales) as sales from man
group by year,month)



select raj.year,total,month,sales from raj
left join ma
on raj.year=ma.year
order by year,month

--Top 5 products by revenue
select product_name ,sum(sales) from man
group by product_name
order by sum(sales) desc
--Total quantity sold per category
select product_category ,sum(quantity) from man
group by product_category
order by sum(quantity) desc

--Top 5 customers by total spending
select top 5 * from (select customer_id,sum(sales)as total-sppending from man
group by customer_id)as f
order by ff desc





--Rank products within each category based on revenue

--👉 (Use PARTITION BY product_category)
select * ,row_number() over(partition by  product_category order by t desc) as rank from
(select product_category, product_name,sum(sales)as t
from man
group by product_category, product_name) as r
order by  product_category

--Find repeat customers
--👉 (Customers who placed more than 1 order)
select customer_id,count(customer_id)
from man
group by customer_id
--the number of repeated customer
select count(r) repeated_customer from 
(select customer_id,count(customer_id)as r,sum(sales)as d
from man
group by customer_id)as f
where r>1

--Compare revenue of repeat vs new customers
select sum(d) repeated_customer_revenue from 
(select customer_id,count(customer_id)as r,sum(sales)as d
from man
group by customer_id)as f
where r>1;
select sum(d) new_customer_revenue from 
(select customer_id,count(customer_id)as r,sum(sales)as d
from man
group by customer_id)as f
where r=1

--Find the highest revenue generating region in each year
select * from(select * ,rank() over (partition by year order  by sales)  as d from
(select year,region,sum(sales)as sales from man
group by year,region)as f)as g
where d=1


--Calculate cumulative revenue over time
--👉 (Use SUM() OVER ORDER BY date)
select cast(order_date as date),sales,sum(sales)over(order by order_date) from man
--Find customer lifetime value (CLV)
--👉 (Total spend per customer)
--who are  spend more
select customer_id,sum(sales) from man
group by customer_id
order by sum(sales)

--Find anomaly
--👉 Orders with high sales but low quantity
select  customer_id,product_name,sales,quantity from man
where sales>(select avg(sales) from man) and quantity<(select avg(quantity) from man)


--Find month with highest growth
with raj as (select year ,sum(sales) total from man
group by year)
,ma as (
select year,month,sum(sales) as sales from man
group by year,month),ma1 as(
select *,rank() over(partition by year order by sales)as rank from ma)




select raj.year,total,month,sales from raj
left join ma1
on raj.year=ma1.year
where rank =1

order by year,month

--Using CTE:
--👉 Top 3 customers per region
with manoj as (
select region ,customer_id,sum(sales) revenue from man
group by region,customer_id
),s as (
select * ,rank () over (partition by region order by revenue desc ) as rank
from manoj
)

select * from s
where rank in (1,2,3)