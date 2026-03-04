/*
CTE types
	Rules: ORDER BY clause cannot be used within the CTE
	1. Non-Recursive
		1.1 Standalone CTE
		- Defined and used independently
			- Runs independently as it's self-contained and does not rely on other CTEs or Queries
			- The cte runs independently and the main query runs depend on the cte in which it will run after the cte runs
			- How to create CTE
				With 'the name of the cte' AS
					(
					select..
					from..
					where..
					)
			1.1.1 Only 1 standalone cte extracts data from the database and 1 main query extracts data from the cte
			1.1.2 Multiple standalone ctes
				- multiple ctes where they have nothing to do with each other
				- multiple ctes directly extract data from the database and query the database
				- example: 4 standalone ctes generate 4 different intermediate results that 
						   have nothing to do with each other (all 4 ctes are independent to each other)
		1.2 Nested CTE
	2. Recursive
*/

--1.1.1 Only 1 cte extracts data from the database and 1 main query extracts data from the cte
-- Step 1: Find the total sales per customer
with totalsalescte as
(
select
	[sls_customerid],
	sls_sales,
	sum(sls_sales) over (partition by sls_customerid) as totalsales
from bronze.sales_orders
)
-- Step 2: Main query to extract data from the database joined with the cte data
select distinct
	c.sls_customerid,
	c.[sls_firstname],
	c.[sls_lastname],
	cte.totalsales
from bronze.sales_customer c
left join totalsalescte cte
on cte.sls_customerid = c.sls_customerid;

/*
select distinct
	[sls_customerid],
	totalsales
from totalsalescte
*/

-- Step 1: Find the total sales per customer
with totalsalescte as
(
select
	[sls_customerid],
	sum(sls_sales) as totalsales
from bronze.sales_orders
group by sls_customerid
)
-- Step 2: Main query to extract data from the database joined with the cte data
select
	c.sls_customerid,
	c.[sls_firstname],
	c.[sls_lastname],
	cte.totalsales
from bronze.sales_customer c
left join totalsalescte cte
on cte.sls_customerid = c.sls_customerid
order by cte.totalsales desc

/*
		1.1.2 Multiple ctes

		1.2 Nested CTE

	2. Recursive
*/

