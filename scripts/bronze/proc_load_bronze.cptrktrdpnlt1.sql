-- THIS SCRIPT IS USED TO LOAD BRONZE LAYER AND IT WILL BE USED IN DAILY BASIS
-- IT WILL BE RUN EVERYDAY IN ORDER TO GET NEW CONTENT TO DATA WAREHOUSE
-- SO WE SHOULD CREATE STORED PROCEDURES FROM THE SCRIPT

/*
=======================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=======================================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions:
		- Truncates the bronze tables before loading data
		- Bulk Inserts data from csv files into bronze tables

Parameters:
	None
	This stored procedure does not accept any parameters or return any values

Usage Example:
	Exec bronze.load_bronze;
=======================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=================================================';

		PRINT '-------------------------------------------------';
		PRINT 'Loading Sales Tables';
		PRINT '-------------------------------------------------';
		PRINT '';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.sales_customer';
		TRUNCATE TABLE bronze.sales_customer;

		PRINT '>> Inserting Data Into: bronze.sales_customer';
		BULK INSERT bronze.sales_customer
		FROM 'C:\Users\Admin\Documents\Data Baraa\sql-ultimate-course-main\datasets\Customers.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------';
		PRINT '';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.sales_employees';
		TRUNCATE TABLE bronze.sales_employees;

		PRINT '>> Inserting Data Into: bronze.sales_employees';
		BULK INSERT bronze.sales_employees
		FROM 'C:\Users\Admin\Documents\Data Baraa\sql-ultimate-course-main\datasets\Employees.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------';
		PRINT '';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.sales_orders';
		TRUNCATE TABLE bronze.sales_orders;

		PRINT '>> Inserting Data Into: bronze.sales_orders';
		BULK INSERT bronze.sales_orders
		FROM 'C:\Users\Admin\Documents\Data Baraa\sql-ultimate-course-main\datasets\Orders.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------';
		PRINT '';
						
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.sales_ordersarchive';
		TRUNCATE TABLE bronze.sales_ordersarchive;

		PRINT '>> Inserting Data Into: bronze.sales_ordersarchive';
		BULK INSERT bronze.sales_ordersarchive
		FROM 'C:\Users\Admin\Documents\Data Baraa\sql-ultimate-course-main\datasets\OrdersArchive.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------';
		PRINT '';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.sales_products';
		TRUNCATE TABLE bronze.sales_products;

		PRINT '>> Inserting Data Into: bronze.sales_products';
		BULK INSERT bronze.sales_products
		FROM 'C:\Users\Admin\Documents\Data Baraa\sql-ultimate-course-main\datasets\Products.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------';
		PRINT '';
		
		SET @batch_end_time = GETDATE();
		PRINT '====================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '  - Total Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '====================================================';
		PRINT '';
	END TRY
	BEGIN CATCH
		PRINT '====================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '====================================================';
	END CATCH
END

