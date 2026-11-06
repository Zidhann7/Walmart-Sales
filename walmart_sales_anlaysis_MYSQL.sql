create database walmart;
use walmart;

select * from walmart_sales
limit 5;

select distinct payment_method from walmart_sales;
-- Number of transactions each payment method
select payment_method,count(*) as transactions from walmart_sales
group by payment_method;

-- hou many different stores are there 

select count(distinct branch) from walmart_sales;

-- Maximum Quanatity 

select max(quantity) from walmart_sales;

-- Business Probelem
-- Q1. Find different payment method and number of transaction, number of qty sold 

select payment_method,count(*) as transactions,sum(quantity) as total_quantity_sold
from walmart_sales
group by payment_method;

-- Q2. Identify the highest rated category in each branch, displaying the branch, category , avg rating
select * 
from
(
select 
branch,category,
avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as 
rank_pos from walmart_sales
group by branch,category
) t
where rank_pos = 1;

-- Q3. Identify the  busiest day for each branch  based on the number of transactions

select branch,date,count(*) as
transcation
from walmart_sales
group by branch,date
order by branch,transcation desc;

-- Q4. Calculate the total quantity of items sold per payment method. list payment_method and total_quantity

select payment_method,sum(quantity) as total_qty 
from walmart_sales
group by payment_method
order by total_qty desc;

-- Q5. Determine the average, minimum , and maximum  rating of products for each city. list the city 
-- , average rating, min_rating, and max_rating

select city,category,
avg(rating) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from
walmart_sales
group by 1,2;

-- Q6. Calculate the profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
-- list category and total_profit, ordered from highest to lower profit

select category, sum(total) as total_revenue,
sum(total*profit_margin) as profit from 
walmart_sales 
group by category;

-- Q7. Determine the most common payment method for each branch. Display branch and the preferred_payment_method
select * from
(
select 
branch,
payment_method,
count(*) as transcations,
rank() over(partition by branch order by count(*) desc) as rank_pos
from walmart_sales
group by 1,2
) t
where rank_pos = 1;

-- or
with cte 
as 
(select 
branch,
payment_method,
count(*) as transcations,
rank() over(partition by branch order by count(*) desc) as rank_pos
from walmart_sales
group by 1,2
)
select * from cte
where rank_pos = 1;

-- Q8. Categorize sales into 3 groups, afternoon, evening find out each of the shift and number of invoices 

select branch,
case 
when time(time) between '00:00:00' and '12:00:00' then 'Morining'
when time(time) between '12:00:00' and '17:00:00' then 'Afternoon'
else 'Evening'
end as time_category,count(*) as no_transcation ,sum(total) as total_sales from walmart_sales
group by 1,2
order by 1,3 desc;


-- Q9. Identify 5 branch with highest decrease ratio in revenue compare to last year(current year 2023 and last year 2022)
-- formula : rde = lastyear_rev - currentyear_rev/lastyear_rev * 100

-- Revenue 2022
with revenue_2022 
as
(
	select branch,sum(total) as revenue from walmart_sales
	where year(date) = 2022
	group by 1
),
revenue_2023
as
(
	select branch,sum(total) as revenue from walmart_sales
	where year(date) = 2023
	group by 1
)
select 
ls.branch, ls.revenue as last_year_revenue,cs.revenue as current_year_revenue,
round((ls.revenue - cs.revenue)/ls.revenue * 100,2) as
revenue_decrease_ration
from revenue_2022 as ls join revenue_2023 as cs
on ls.branch = cs.branch
where
	ls.revenue > cs.revenue
order by 4 desc
limit 5;
