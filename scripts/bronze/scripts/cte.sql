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
		- CTE withins CTE
			- A nested cte uses the result of another cte that is why it cannot run independently

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
order by cte.totalsales desc;

------------------------------------------------------------------------------------------------------

--1.1.2 Multiple standalone ctes
-- example: 2 standalone ctes and 1 main query
-- cte 1
with totalsalescte as
(
select
	[sls_customerid],
	sum(sls_sales) as totalsales
from bronze.sales_orders
group by sls_customerid
),
-- cte 2
cte_lastorder as
(
select
	sls_customerid,
	max(sls_orderdate) as lastorder
from bronze.sales_orders
group by sls_customerid
)
-- Step 2: Main query to extract data from the database joined with the cte data
-- main query
select
	c.sls_customerid,
	c.[sls_firstname],
	c.[sls_lastname],
	cte.totalsales,
	lo.lastorder
from bronze.sales_customer c
left join totalsalescte cte
on cte.sls_customerid = c.sls_customerid
left join cte_lastorder lo
on lo.sls_customerid = c.sls_customerid
order by cte.totalsales desc;

------------------------------------------------------------------------------------------------------

-- 1.2 Nested CTE
-- example: 2 standalone ctes and 1 nested cte and 1 main query
-- cte 1 standalone
with totalsalescte as
(
select
	[sls_customerid],
	sum(sls_sales) as totalsales
from bronze.sales_orders
group by sls_customerid
),
-- cte 2 standalone
cte_lastorder as
(
select
	sls_customerid,
	max(sls_orderdate) as lastorder
from bronze.sales_orders
group by sls_customerid
),
-- cte 3 nested
cte_rank as
(
select
	sls_customerid,
	rank() over (order by totalsales desc) as ranksales
from totalsalescte
)
-- main query
select
	c.sls_customerid,
	c.[sls_firstname],
	c.[sls_lastname],
	cte.totalsales,
	lo.lastorder,
	r.ranksales
from bronze.sales_customer c
left join totalsalescte cte
on cte.sls_customerid = c.sls_customerid
left join cte_lastorder lo
on lo.sls_customerid = c.sls_customerid
left join cte_rank r
on r.sls_customerid = c.sls_customerid;

------------------------------------------------------------------------------------------------------

-- 1.2 Nested CTE
-- example: 2 standalone ctes and 2 nested cte and 1 main query
-- cte 1 standalone
with totalsalescte as
(
select
	[sls_customerid],
	sum(sls_sales) as totalsales
from bronze.sales_orders
group by sls_customerid
),
-- cte 2 standalone
cte_lastorder as
(
select
	sls_customerid,
	max(sls_orderdate) as lastorder
from bronze.sales_orders
group by sls_customerid
),
-- cte 3 nested rank customer based on their total sales
cte_rank as
(
select
	sls_customerid,
	case when totalsales is null then ''
		 else rank() over (order by totalsales desc)
	end as ranksales
from totalsalescte
),
-- cte 4 segment customers based on their total sales
cte_segment_cust as
(
select
	sls_customerid,
	case when totalsales > 100 then 'high'
		 when totalsales > 50 then 'medium'
		 else 'low'
	end as customersegment
from totalsalescte
)
-- main query
select
	c.sls_customerid,
	c.[sls_firstname],
	c.[sls_lastname],
	cte.totalsales,
	lo.lastorder,
	r.ranksales,
	sc.customersegment
from bronze.sales_customer c
left join totalsalescte cte
on cte.sls_customerid = c.sls_customerid
left join cte_lastorder lo
on lo.sls_customerid = c.sls_customerid
left join cte_rank r
on r.sls_customerid = c.sls_customerid
left join cte_segment_cust sc
on sc.sls_customerid = c.sls_customerid
order by ranksales;
