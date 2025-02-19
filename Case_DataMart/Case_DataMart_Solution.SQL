use Datamart
Select * from weekly_sales



--Data Cleaning Query
Select week_date,
datepart(week, week_date) as WeeK_number,
month(week_date) as month,
year(week_date) as year, 
region,platform,isnull(segment,'Unknown') as segment,
Case
when right(segment,1) = '1' then 'Young Adults'
when right(segment,1) = '2' then 'Middle Aged'
when right(segment,1) in ( '3' , '4' ) then 'Retirees'
else 'Unknown'
end as Age_band,
Case
when left(segment,1) = 'C' then 'Couples'
when left(segment,1) = 'F' then 'Families'
else 'Unknown'
end as Demographic,
customer_type,
transactions,
sales,
round((sales/transactions),2) as Avg_transaction
into clean_weekly_sales
from weekly_sales



--Data Exploration

Select *  from clean_weekly_sales

--Q1.) Which week numbers are missing from the dataset?

Create Table Seq52 (week_number int primary key);


Insert into Seq52  (week_number) values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
										(11), (12), (13), (14), (15), (16), (17), (18), (19), (20),
										(21), (22), (23), (24), (25), (26), (27), (28), (29), (30),
										(31), (32), (33), (34), (35), (36), (37), (38), (39), (40),
										(41), (42), (43), (44), (45), (46), (47), (48), (49), (50),
										(51), (52);



Select week_number from Seq52 where week_number not in (Select distinct week_number from clean_weekly_sales)

--Q2.) How many total transactions were there for each year in the dataset?

Select sum(transactions) as yearly_transactions,year  from clean_weekly_sales group by year

--Q3.) What are the total sales for each region for each month?

Select month,region,sum(cast(sales as bigint)) as monthly_sales from clean_weekly_sales group by month,region order by month,region

--Q4.) What is the total count of transactions for each platform


Select platform,sum(transactions) count_of_transactions from clean_weekly_sales group by platform

--Q5.) What is the percentage of sales for Retail vs Shopify for each month?

WITH cte_monthly_platform_sales AS (
  SELECT
    month,
    year,
    platform,
    SUM(CAST(sales AS BIGINT)) AS monthly_sales -- Cast sales to BIGINT
  FROM clean_weekly_sales
  GROUP BY month, year, platform
)
SELECT
  month,
  year,
  ROUND(
    100.0 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) / 
      CAST(SUM(monthly_sales) AS DECIMAL(18, 2)), 
    2
  ) AS retail_percentage,
  ROUND(
    100.0 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) / 
      CAST(SUM(monthly_sales) AS DECIMAL(18, 2)), 2
  ) AS shopify_percentage
FROM cte_monthly_platform_sales
GROUP BY month, year
ORDER BY year, month;



--Q6. ) What is the percentage of sales by demographic for each year in the dataset?

Select * from clean_weekly_sales

SELECT
  year,
  demographic,
  SUM(cast(sales as bigint)) AS yearly_sales,
  ROUND(
    (
      100.0 * CAST(SUM(cast(sales as bigint)) AS DECIMAL(18, 2)) /
      CAST(SUM(SUM(cast(sales as bigint))) OVER (PARTITION BY demographic) AS DECIMAL(18, 2))
    ),
    2
  ) AS percentage
FROM clean_weekly_sales
GROUP BY
  year,
  demographic
ORDER BY
  year,
  demographic;

--Q7.) Which age_band and demographic values contribute the most to Retail sales?


Select age_band,Demographic,sum(cast(sales as bigint)) as Max_sales
from clean_weekly_sales
where platform='Retail'
group by age_band,Demographic
order by Max_sales desc