--Case Data Bank 
Use DataBank
--Tables

Select * from regions
Select * from customer_transactions
Select * from customer_nodes

--Questions

--Q1.) How many different nodes make up the Data Bank network?


Select count(distinct node_id) as unique_nodes from customer_nodes 

--Q2.) How many nodes are there in each region?

Select 
r.region_name,count(cn.node_id) as Number_of_nodes
from customer_nodes as cn join regions as r
on cn.region_id = r.region_id
group by r.region_name


--Q3.) How many customers are divided among the regions?


Select 
r.region_name,count(distinct cn.customer_id) as Number_of_Customers
from customer_nodes as cn join regions as r
on cn.region_id = r.region_id
group by r.region_name

--Q4.) Determine the total amount of transactions for each region name.

Select 
r.region_name,sum(ct.txn_amount) as Total_amount_transactions
from regions as r 
join customer_nodes as cn
on r.region_id = cn.region_id
join customer_transactions as ct
on cn.customer_id = ct.customer_id
group by r.region_name
 
--Q5.) How long does it take on an average to move clients to a new node?

Select avg(datediff(DAY,start_date,end_date)) as avg_days from customer_nodes where end_date != '9999-12-31'

--Q6.) What is the unique count and total amount for each transaction type?

Select txn_type, count(*) as count_tran,sum(txn_amount) as total_amount 
from customer_transactions 
group by txn_type




--Q7.) For each month - how many Data Bank customers 
--make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month?



WITH transaction_count_per_month_cte AS
(
    SELECT 
        customer_id,
        MONTH(txn_date) AS txn_month,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM 
        customer_transactions
    GROUP BY 
        customer_id, 
        MONTH(txn_date)
)
SELECT 
    txn_month,
    COUNT(DISTINCT customer_id) AS customer_count
FROM 
    transaction_count_per_month_cte
WHERE 
    deposit_count > 1
    AND 
    (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY 
    txn_month;



