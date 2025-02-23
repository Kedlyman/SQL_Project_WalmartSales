create database if not exists salesDataWalmart;

create table if not exists sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10, 2) not null,
    quantity int not null,
    VAT float(6, 4) not null,
    total decimal(12, 4) not null,
    date datetime not null,
    time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10, 2) not null,
    gross_margin_pct float(11, 9),
    gross_income decimal(12, 4) not null,
    rating float(2, 1)
);



-- ----------------------------------------------------------------------
-- ---------------------------Feature Engineering------------------------

-- time_of_day

select
	time,
    case
		when time between '00:00:00' and '12:00:00' then 'Morning'
        when time between '12:01:00' and '16:00:00' then 'Afternoon'
        else 'Evening'
    end as time_of_day
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = (
	case
		when time between '00:00:00' and '12:00:00' then 'Morning'
        when time between '12:01:00' and '16:00:00' then 'Afternoon'
        else 'Evening'
    end
);

-- day_name
select 
	date,
    dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(date);

-- month_name
select
	date,
    monthname(date) as month_name
from sales;

alter table sales add column month_name varchar(10);

update sales
set month_name = monthname(date);

-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- ---------------------------Generic------------------------------------

-- How many unique cities does the data have ?
select
	distinct city
from sales;

-- In which city is each branch?
select
	distinct city,
    branch
from sales;

-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- ---------------------------Product------------------------------------

-- How many unique product lines does the data have?
select
	distinct product_line
from sales;

-- What is the most common payment method?
select 
	payment_method,
    count(payment_method) as count_payment_method
from sales
group by payment_method 
order by count_payment_method desc;

-- What is the most selling product line?
select 
	product_line,
    count(product_line) as count_product_line
from sales
group by product_line 
order by count_product_line desc;

-- What is the total revenue by month?
select
	month_name as month,
    sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- What month had the largest COGS?
select
	month_name as month,
    sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;

-- What product line had the largest revenue?
select
	product_line,
    sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- What is the city with the largest revenue?
select
	branch,
	city,
    sum(total) as total_revenue
from sales
group by city, branch
order by total_revenue desc;

-- What product line had the largest VAT?
select 
	product_line,
    sum(VAT) as total_vat
from sales
group by product_line
order by total_vat desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select 
    product_Line,
    sum(total) as TotalSales,
    avg(sum(total)) over () as AverageSales,
    case 
        when sum(Total) > avg(sum(Total)) over () then 'Good'
        else 'Bad'
    end as SalesStatus
from 
    sales
group by 
    product_line;

    -- Which branch sold more products than average product sold?
    select 
		branch,
        sum(quantity) as qty
	from sales
    group by branch
    having sum(quantity) > (select avg(quantity) from sales);
    
    -- What is the most common product line by gender?
    select
		gender,
        product_line,
        count(gender) as total_cnt
	from sales
    group by gender, product_line
    order by total_cnt desc;

-- What is the average rating of each product line?
select
	product_line,
    round(avg(rating), 2) as avg_rtng
from sales
group by product_line
order by avg_rtng desc;

-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- ---------------------------Sales--------------------------------------

-- Number of sales made in each time of the day per weekday
select
	time_of_day,
    count(*) as total_sales
from sales
where day_name = "Monday"
group by time_of_day
order by total_sales desc;

-- Which of the customer types brings the most revenue?
select
	customer_type,
    sum(total) as total_rev
from sales
group by customer_type
order by total_rev desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select
	city,
    avg(VAT) as vat
from sales
group by city
order by vat desc;

-- Which customer type pays the most in VAT?
select
	customer_type,
    sum(VAT) as vat
from sales
group by customer_type
order by vat desc;

-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
-- ---------------------------Customer--------------------------------------

-- How many unique customer types does the data have?
select
	distinct customer_type
from sales;

-- How many unique payment methods does the data have?
select
	distinct payment_method
from sales;

-- What is the most common customer type?
select
	customer_type,
    count(*) as total_count
from sales
group by customer_type
order by total_count desc;

-- Which customer type buys the most?
select
	customer_type,
    count(*) as total_count
from sales
group by customer_type
order by total_count desc;

-- What is the gender of most of the customers?
select
	gender,
    count(*) as total_count
from sales
group by gender
order by total_count desc;

-- What is the gender distribution per branch?
select
	branch,
    gender,
    count(*) as count
from sales
group by branch, gender;

-- Which time of the day do customers give most ratings?
select 
	time_of_day,
    count(rating) as total_rating
from sales
group by time_of_day
order by total_rating desc;

-- Which time of the day do customers give most ratings per branch?
select 
	time_of_day,
    branch,
    count(rating) as total_rating
from sales
group by time_of_day, branch
order by total_rating desc;

-- Which day of the week has the best avg ratings?
select
	day_name,
    avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

-- Which day of the week has the best average ratings per branch?
select
	day_name,
    branch,
    avg(rating) as avg_rating
from sales
group by day_name, branch
order by avg_rating desc;

    




