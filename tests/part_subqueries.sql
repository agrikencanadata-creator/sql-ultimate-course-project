/*
These are scripts I used to learn about chapter subqueries in Data With Baraa channel
*/

/*
Task: Find the products that have a price higher than the average price of all products
*/
select
*
from
(
	select
		sls_productid,
		sls_price,
		avg(sls_price) over () as avg_price
		-- avg(sls_price) over (partition by sls_productid) as avg_price_by_product
	from bronze.sales_products
)t
where sls_price > avg_price

/*
Task: Rank customer based on their total amount of sales
*/

select
	sls_customerid,
	sum(sls_sales) as total_sales,
	rank() over( order by sum(sls_sales) desc) rank
from
(
	select
		[sls_customerid],
		sls_sales,
		sum(sls_sales) over () as total_sales,
		sum(sls_sales) over(partition by sls_customerid) as total_sales_by_customerid
	from bronze.sales_orders
)t
group by sls_customerid

-------------------------------------------------------------------------------------------

select
	sls_customerid,
	total_sales_by_customerid,
	rank() over( order by total_sales_by_customerid desc) rank
from
(
	select
		[sls_customerid],
		sls_sales,
		sum(sls_sales) over () as total_sales,
		sum(sls_sales) over(partition by sls_customerid) as total_sales_by_customerid
	from bronze.sales_orders
)t
group by sls_customerid, total_sales_by_customerid

-------------------------------------------------------------------------------------------

select
	sls_productid,
	sls_price,
	(select
		avg(sls_price)
	 from bronze.sales_products) as avgprice
from bronze.sales_products
where sls_price >  (select
						avg(sls_price)
					from bronze.sales_products)

-------------------------------------------------------------------------------------------

/*
Show the product ids, product names, prices, and the total number of orders
*/
-- main query
select
	sls_productid,
	sls_product,
	sls_price,
	-- subquery
	(select
		count(*) as totalorders
	from bronze.sales_orders) as totalorders_subquery
from bronze.sales_products;


-- subquery
select
	count(*) as totalorders
from bronze.sales_orders

-------------------------------------------------------------------------------------------

/*
Show all customer details and find the total orders of each customer
*/
-- Main query
select
	sc.*,
	so.totalorders
from bronze.sales_customer sc
left join	(select
				sls_customerid,
				count(*) as totalorders
		 	 from bronze.sales_orders
			 group by sls_customerid
			) so
on so.sls_customerid = sc.sls_customerid

-- subquery
select
	sls_customerid,
	count(*) as totalorders
from bronze.sales_orders
group by sls_customerid

-------------------------------------------------------------------------------------------

/*
Show the details of orders made by customers in Germany
*/

select
*
from bronze.sales_orders
where sls_customerid not IN (select
							sls_customerid
						 from bronze.sales_customer
						 where sls_country = 'Germany');

select
*
from bronze.sales_customer
where sls_country = 'Germany'

---------------------------------------------------------------------------------------

select
*
from bronze.sales_customer
where sls_country = 'Germany'

-- Main query
select
*
from bronze.sales_orders so
where not exists	(
				 select
					1
				 from bronze.sales_customer sc
				 where sls_country = 'Germany'
				 and sc.sls_customerid = so.sls_customerid
				)

-------------------------------------------------------------------------------------------

/*
Find Females employees whose salaries are greater than the salaries of any male employees
*/

-- Main Query
select
	[sls_employeeid],
	[sls_firstname],
	[sls_gender],
	[sls_salary]
from bronze.sales_employees
where sls_gender = 'F'
AND sls_salary > ANY (select
						[sls_salary]
					 from bronze.sales_employees
					 where sls_gender = 'M')

select
	[sls_employeeid],
	[sls_firstname],
	[sls_gender],
	[sls_salary]
from bronze.sales_employees
where sls_gender = 'M'

---------------------------------------------------------------------------------------------

/*
Find Females employees whose salaries are greater than the salaries of aLL male employees
*/

-- Main Query
select
	[sls_employeeid],
	[sls_firstname],
	[sls_gender],
	[sls_salary]
from bronze.sales_employees
where sls_gender = 'F'
AND sls_salary > ALL (select
						[sls_salary]
					 from bronze.sales_employees
					 where sls_gender = 'M')

---------------------------------------------------------------------------------------------

/*
Find Females employees whose salaries are less than or equal to the salaries of aLL male employees
*/

-- Main Query
select
	[sls_employeeid],
	[sls_firstname],
	[sls_gender],
	[sls_salary]
from bronze.sales_employees
where sls_gender = 'F'
AND sls_salary <= ALL (select
						[sls_salary]
					 from bronze.sales_employees
					 where sls_gender = 'M')

-------------------------------------------------------------------------------------------

/*
Show all customer details and find out the total orders of each customer
*/

-- main query
select
	*,
	(select count(*) from bronze.sales_orders so where so.sls_customerid = sc.sls_customerid) as totalsalesbycustomer
from bronze.sales_customer sc

-------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------
