/*
===================================================
Create Database and Schemas
===================================================
Script Purpose:
  This script creates a new database named 'Ultidbstut1' after checking if it already exists.
  If the database exists, it is  dropped and recreated.
  Additionally, the script sets up 3 schemas within the database: 'bronze', 'silver', and 'gold'.

Warning:
Running this script will drop the entire 'Ultidbstut1' database if it already exists.
All data in the database will be permanently deleted. 
Process with caution and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'Ultidbstut1' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Ultidbstut1')
BEGIN
	ALTER DATABASE Ultidbstut1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Ultidbstut1;
END;
GO

-- Create the 'Ultidbstut1' database
CREATE DATABASE Ultidbstut1;
GO

USE Ultidbstut1;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
