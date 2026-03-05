/*
CTE types
	Rules: ORDER BY clause cannot be used within the CTE
	1. Non-Recursive CTE
		- It is executed only once without repetition
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

	2. Recursive CTE
		- Self-referencing query that repeatedly processes data until a specific condition is met
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
-- example 1: 2 standalone ctes and 1 nested cte and 1 main query
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
-- example 2: 2 standalone ctes and 2 nested cte and 1 main query
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
	case when totalsales = null then ''
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
order by totalsales desc;

------------------------------------------------------------------------------------------------------

-- 2. Recursive CTE

with base as
(
-- Anchor query
select
1 as number
UNION ALL
-- recursive query
select
number + 1
from base
where number < 20
)

select
*
from base
option (maxrecursion 5000);

-- Example : Show the employee hierarchy by displaying each employee's level within the organization

with cte_employee_hierarchy as
(
-- Anchor query
select
	[sls_employeeid],
	[sls_firstname],
	[sls_managerid],
	1 as level
from bronze.sales_employees
where sls_managerid is null

union all
-- Recursive query
select
	e.sls_employeeid,
	e.sls_firstname,
	e.sls_managerid,
	-- 2 as level
	level + 1
from bronze.sales_employees as e
inner join cte_employee_hierarchy ceh
on e.sls_managerid = ceh.sls_employeeid
-- where e.sls_managerid = 1
-- fyi for the 2nd iteration that has sls_managerid = 1, the recursive will run until it reaches and stops
-- when it finds the sls_employeeid which has the same value as the sls_managerid
-- realization: 2nd iteration -> sls_managerid = 1 then when recursive cte running it will stop by the time
-- it finds sls_employeeid = 1
--		then the level will be the current level reference (1 sls_employeeid) which is
--		level + 1 = 1 + 1 = 2

-- for the 3rd iteration, sls_managerid = 1, the recursive cte stops when it finds sls_employeeid = 1
--		then the new level will be the current level reference (1 sls_employeeid) level which is
--		level + 1 = 1 + 1 = 2

-- for the 4th iteration, sls_managerid = 3, the recursive cte stops when it finds sls_employeeid = 3
--		then the new level will be the current level reference (2 sls_employeeid) level which is
--		level + 1 = 2 + 1 = 3

-- for the 5th iteration, sls_managerid = 2, the recursive cte stops when it finds sls_employeeid = 2
--		then the new level will be the reference (2 sls_employeeid) level which is
--		level + 1 = 2 + 1 = 3
)

select 
	*
from cte_employee_hierarchy;

select
	[sls_employeeid],
	[sls_firstname],
	[sls_managerid],
	1 as level
from bronze.sales_employees;
