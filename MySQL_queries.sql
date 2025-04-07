1.  Provide the list of markets in which customer  "Atliq  Exclusive"  operates its business in the  APAC  region.
  
  select distinct market 
  from dim_customer 
  where customer = 'Atliq Exclusive' and region = 'APAC';

****************************************************************************************************************************

2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, 
unique_products_2020 
unique_products_2021 
percentage_chg

select p1.unique_products_2020, 
	p2.unique_products_2021, 
	round((unique_products_2021-unique_products_2020)/unique_products_2020*100, 2) as percentage_chg
from 
	(select count(distinct product_code) as unique_products_2020
	from fact_sales_monthly
	where fiscal_year =2020) p1
join
	(select count(distinct product_code) as unique_products_2021
	from fact_sales_monthly
	where fiscal_year =2021) p2;

******************************************************************************************************************************

3. Provide a report with all the unique product counts for each  segment  and sort them in descending order of product counts. 
   The final output contains 2 fields, 
segment 
product_count 

select  segment, 
	count(distinct product_code) as product_count
from dim_product 
group by segment 
order by product_count desc;

******************************************************************************************************************************

4.  Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields, 
segment 
product_count_2020 
product_count_2021 
difference

with cte1 as (
	select  
    p.segment, 
    count(distinct (case when fiscal_year=2020 then f.product_code end)) as product_count_2020,
    count(distinct (case when fiscal_year=2021 then f.product_code end)) as product_count_2021
	from dim_product p
	join fact_sales_monthly f
	on p.product_code = f.product_code
	group by segment 
    )
    
select segment, 
	product_count_2020, 
    product_count_2021, 
	(product_count_2021-product_count_2020) as difference
from cte1 
order by difference desc;

****************************************************************************************************************************

5.  Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields, 
product_code 
product 
manufacturing_cost

select m.product_code, 
	p.product, 
	round(m.manufacturing_cost,2)
from dim_product p 
join fact_manufacturing_cost m
on p.product_code = m.product_code
where m.manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost) or
	  m.manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost) 
order by m.manufacturing_cost desc;

*****************************************************************************************************************************

6.  Generate a report which contains the top 5 customers who received an average high  pre_invoice_discount_pct  for the  
    fiscal  year 2021  and in the Indian  market. The final output contains these fields, 
customer_code 
customer 
average_discount_percentage

select f.customer_code,
	c.customer, 
	round(avg(f.pre_invoice_discount_pct*100),2) as average_discount_percentage
from dim_customer c
join fact_pre_invoice_deductions f
on c.customer_code = f.customer_code
where f.fiscal_year=2021 and c.market = 'India'
group by f.customer_code, c.customer
order by average_discount_percentage desc
limit 5;

******************************************************************************************************************************

7.  Get the complete report of the Gross sales amount for the customer  “Atliq Exclusive”  for each month. This analysis helps 
    to  get an idea of low and high-performing months and take strategic decisions. The final report contains these columns: 
Month 
Year 
Gross sales Amount 

select date_format(f.date, '%b') as month, 
	date_format(f.date, '%Y') as year, f.fiscal_year, 
	round(sum(g.gross_price*f.sold_quantity)/1000000, 2) as gross_sales_amount_mln
from  dim_customer d
join fact_sales_monthly f 
on d.customer_code = f.customer_code
join fact_gross_price g
on f.product_code = g.product_code
where d.customer='Atliq Exclusive'
group by month, year, f.fiscal_year
order by year;

********************************************************************************************************************************************

8.   In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity, 
Quarter 
total_sold_quantity 

select case
       when month(date) in (9,10,11) then 'Q1'
       when month(date) in (12,1,2) then 'Q2'
       when month(date) in (3,4,5) then 'Q3'
       else 'Q4' end as quarter, 
	   sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly
where fiscal_year=2020
group by quarter
order by total_sold_quantity desc;

*******************************************************************************************************************************************************
  
9.  Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?  The final output  contains these fields, 
channel 
gross_sales_mln 
percentage 

with cte as (
	select d.channel, 
		round(sum(g.gross_price*f.sold_quantity)/1000000, 2) as gross_sales_mln
from dim_customer d
join fact_sales_monthly f 
on d.customer_code = f.customer_code
join fact_gross_price g
on f.product_code = g.product_code
where g.fiscal_year = 2021
group by d.channel
	)

select channel, 
	gross_sales_mln,
	round(gross_sales_mln*100/sum(gross_sales_mln) over (),2) as percentage
from cte
group by channel
order by percentage desc;

**************************************************************************************************************************************************

10.  Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields, 
division 
product_code  
product 
total_sold_quantity 
rank_order 

with cte1 as (
	select p.division, 
		f.product_code, 
        p.product, 
		sum(f.sold_quantity) as total_sold_quantity
	from dim_product p
	join fact_sales_monthly f
	on p.product_code = f.product_code
	where f.fiscal_year = 2021
	group by p.division, f.product_code, p.product
	),

cte2 as (
	select division, 
		product_code, 
		product, 
		total_sold_quantity,
		dense_rank() over (partition by division order by total_sold_quantity desc) as rank_order
	from cte1
	)
select * 
from cte2
where rank_order < 

