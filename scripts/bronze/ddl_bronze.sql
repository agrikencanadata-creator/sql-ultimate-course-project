/*
================================================================================
DDL Script: Create Bronze Tables
================================================================================
Script Purpose:
	This script creates tables in the 'bronze' schema, dropping existing tables
	if they already exist.
	Run this script to re-define the DDL structure of the 'bronze' Tables
================================================================================
*/

IF OBJECT_ID ('bronze.sales_customer','U') IS NOT NULL
	DROP TABLE bronze.sales_customer;
CREATE TABLE bronze.sales_customer(
	sls_customerid				INT,
	sls_firstname				NVARCHAR(50),
	sls_lastname				NVARCHAR(50),
	sls_country					NVARCHAR(50),
	sls_score					INT
);
GO

IF OBJECT_ID ('bronze.sales_employees','U') IS NOT NULL
	DROP TABLE bronze.sales_employees;
CREATE TABLE bronze.sales_employees(
	sls_employeeid				INT,
	sls_firstname				NVARCHAR(50),
	sls_lastname				NVARCHAR(50),
	sls_department				NVARCHAR(50),
	sls_birthdate				DATE,
	sls_gender					NVARCHAR(50),
	sls_salary					INT,
	sls_managerid				INT
);
GO

IF OBJECT_ID ('bronze.sales_orders','U') IS NOT NULL
	DROP TABLE bronze.sales_orders;
CREATE TABLE bronze.sales_orders (
	sls_orderid				INT,
	sls_productid			INT,
	sls_customerid			INT,
	sls_salespersonid		INT,
	sls_orderdate			DATE,
	sls_shipdate			DATE,
	sls_orderstatus			NVARCHAR(50),
	sls_shipaddress			NVARCHAR(50),
	sls_billaddress			NVARCHAR(50),
	sls_quantity			INT,
	sls_sales				INT,
	sls_creationtime		DATETIME
);
GO

IF OBJECT_ID ('bronze.sales_ordersarchive','U') IS NOT NULL
	DROP TABLE bronze.sales_ordersarchive;
CREATE TABLE bronze.sales_ordersarchive (
	sls_orderid				INT,
	sls_productid			INT,
	sls_customerid			INT,
	sls_salespersonid		INT,
	sls_orderdate			DATE,
	sls_shipdate			DATE,
	sls_orderstatus			NVARCHAR(50),
	sls_shipaddress			NVARCHAR(50),
	sls_billaddress			NVARCHAR(50),
	sls_quantity			INT,
	sls_sales				INT,
	sls_creationtime		DATETIME
);
GO

IF OBJECT_ID ('bronze.sales_products','U') IS NOT NULL
	DROP TABLE bronze.sales_products;
CREATE TABLE bronze.sales_products (
	sls_productid			INT,
	sls_product				NVARCHAR(50),
	sls_category			NVARCHAR (50),
	sls_price				INT
);
GO
