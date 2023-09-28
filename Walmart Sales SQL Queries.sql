create database WalmartSalesData;

create table Sales(
invoice_id varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type VARCHAR(30) not null,
gender VARCHAR(10) not null,
product_line VARCHAR(100) not null,
unit_price DECIMAL(10, 2) not null,
quantity INT not null,
VAT FLOAT(6, 4) not null,
total DECIMAL(12,4)  not null,
date DATETIME not null,
time TIME  not null,
payment_method VARCHAR(15)  not null,
cogs DECIMAL(10, 2)  not null,
gross_margin_percentag FLOAT(11, 9)  not null,
gross_income DECIMAL(12,4)  not null,
rating FLOAT(2, 1)  not null
);


--- ---------------------------- FEATURE ENGINEERING ---------------------------------------------------------------------------------------------- ---

--- TIME OF DAY ---

select time,
		(case
			when time between "00:00:00" and "12:00:00" then "Morning"
			when time between "12:01:00" and "16:00:00" then "Afternoon"
            else "Evening"
		end
        ) as time_of_date
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = (
case
	 when time between "00:00:00" and "12:00:00" then "Morning"
	 when time between "12:01:00" and "16:00:00" then "Afternoon"
	 else "Evening"
     end
);


--- DAY_NAME ---

select date,
	dayname(date)
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(date);


--- MONTH_NAME ---

select date, 
	monthname(date)
from sales;

alter table sales add column month_name varchar(10);

update sales
set month_name = monthname(date);


--- -------------------------- EXPLORATORY DATA ANALYSIS ------------------------------------------------------------------------------------------ ---

--- ------- GENERIC QUESTIONS --------------------------------------------------------------------------------------------------------------------- ---

-- How many unique cities does the data have?

select distinct city 
from sales;

-- Yangon, Naypyitaw, Mandalay --

-- In which city is each branch?

select distinct city, branch 
from sales;

-- Yangon	 A
-- Naypyitaw C
-- Mandalay	 B

--- ---------- PRODUCT QUESTIONS ------------------------------------------------------------------------------------------------------------------ ---

-- How many unique product lines does the data have?

SELECT COUNT(DISTINCT product_line)
from sales;

-- 6

-- What is the most common payment method?

select payment_method,count(payment_method)
from sales
group by payment_method
order by count(payment_method) desc;

-- Cash	        344
-- Ewallet	    342
-- Credit card	309

-- What is the most selling product line?

select product_line, count(product_line)
from sales
group by product_line
order by count(product_line) desc;

-- Fashion accessories	    178
-- Food and beverages	    174
-- Electronic accessories	169
-- Sports and travel	    163
-- Home and lifestyle	    160
-- Health and beauty	    151

-- What is the total revenue by month?

select  month_name as month, sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- January	116291.8680
-- March	108867.1500
-- February	95727.3765

-- What month had the largest COGS?

select month_name as month, sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;

-- January	110754.16
-- March	103683.00
-- February	91168.93

-- What product line had the largest revenue?

select product_line, sum(total) as revenue
from sales
group by product_line
order by revenue desc;

-- Food and beverages	56144.8440
-- Fashion accessories	54305.8950
-- Sports and travel	53936.1270
-- Home and lifestyle	53861.9130
-- Electronic accessories	53783.2365
-- Health and beauty	48854.3790

-- What is the city with the largest revenue?

select branch, city, sum(total) as revenue
from sales
group by city, branch
order by revenue desc;

-- C	Naypyitaw	110490.7755
-- A	Yangon	    105861.0105
-- B	Mandalay	104534.6085

-- What product line had the largest VAT?

select product_line, avg(VAT) as avg_tax
from sales
group by product_line
order by avg_tax desc
limit 1;

-- Home and lifestyle	16.03033124

-- Which branch sold more products than average product sold?

select branch, sum(quantity)
from sales
group by branch
having sum(quantity) > (select avg(quantity)from sales);

-- A	1849
-- C	1828
-- B	1795

-- What is the most common product line by gender?

select gender, product_line, count(gender) as total_count
from sales
group by gender, product_line
order by total_count desc;

-- Female Fashion accessories	96

-- What is the average rating of each product line?

select product_line, round(avg(rating), 2) as avg_rating
from sales
group by product_line
order by avg_rating desc;

-- Food and beverages	    7.11
-- Fashion accessories	    7.03
-- Health and beauty	    6.98
-- Electronic accessories	6.91
-- Sports and travel	    6.86
-- Home and lifestyle	    6.84

--- ------------------------------ SALES --------------------------------------------------------------------------------------------------------- ----

-- Number of sales made in each time of the day per weekday?

select time_of_day,day_name, count(*) as total_sales
from sales
where day_name IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
group by time_of_day, day_name
order by total_sales desc;

-- Which of the customer types brings the most revenue?

select customer_type, round(sum(total), 2) as revenue
from sales
group by customer_type
order by revenue desc;

-- Member	163625.10
-- Normal	157261.29

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

select city, round(avg(VAT), 2) as VAT
from sales
group by city
order by VAT desc;

-- Naypyitaw	16.09
-- Mandalay	    15.13
-- Yangon	    14.87

-- Which customer type pays the most in VAT?

select customer_type, round(avg(VAT), 2) as VAT
from sales
group by customer_type
order by VAT desc;

-- Member	15.61
-- Normal	15.1

--- ------------------------ CUSTOMER ------------------------------------------------------------------------------------------------------------ ----

-- How many unique customer types does the data have?

SELECT DISTINCT(CUSTOMER_TYPE)
FROM SALES;

-- Normal
-- Member

-- How many unique payment methods does the data have?

SELECT DISTINCT(PAYMENT_METHOD)
FROM SALES;

-- Credit card
-- Ewallet
-- Cash

-- What is the most common customer type?

select customer_type, count(customer_type)
from sales
group by customer_type;

-- Normal	496
-- Member	499

-- Which customer type buys the most?

select customer_type, count(*) as customer_count
from sales
group by customer_type;

-- Normal	496
-- Member	499

-- What is the gender of most of the customers?

select gender, count(*) as gender_count
from sales
group by gender
order by gender_count;

-- Female	497
-- Male	498

-- What is the gender distribution per branch?

select gender, branch, count(*) as gender_count
from sales
where branch in ("A" , "B" , "C")
group by gender, branch
order by gender_count desc;

-- Which time of the day do customers give most ratings?

select time_of_day, avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating desc;

-- Afternoon	7.02340
-- Morning	    6.94474
-- Evening	    6.90536

-- Which time of the day do customers give most ratings per branch?

select time_of_day, branch, avg(rating) as avg_rating
from sales
where branch in ("A" , "B" , "C")
group by time_of_day, branch
order by avg_rating, branch desc;

-- Which day fo the week has the best avg ratings?

select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

-- Which day of the week has the best average ratings per branch?

select day_name, branch, avg(rating) as avg_rating
from sales
group by day_name,  branch
order by branch, avg_rating desc;

