/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/



create or alter procedure bronze.load_bronze as
begin

DECLARE @start_time datetime, @end_time datetime,
        @batch_start_time datetime, @batch_end_time datetime

 BEGIN TRY
	PRINT '==== LOADING BRONZE LAYER ====='
    
		print '---- LOADING SOURCE CRM ----'

		set @batch_start_time = getdate()

		set @start_time = getdate()
		truncate table bronze.crm_cust_info

		PRINT '>> INSERTING DATA ON TABLE: bronze.crm_cust_info'
		bulk insert bronze.crm_cust_info
		from  'C:\sql\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print '>>load duration ' + cast( datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '>> ---------------------';


		set @start_time = getdate()
		truncate table bronze.crm_prd_info
		PRINT '>> INSERTING DATA ON TABLE: bronze.crm_prd_info'
		bulk insert bronze.crm_prd_info
		from  'C:\sql\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print '>>load duration ' + cast( datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '>> ---------------------';



		set @start_time = getdate()
		truncate table bronze.crm_sales_details
		PRINT '>> INSERTING DATA ON TABLE: bronze.crm_sales_details'
		bulk insert bronze.crm_sales_details
		from  'C:\sql\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print '>>load duration ' + cast( datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '>> ---------------------';



		print'---- LOADING SOURCE ERP ----'

		set @start_time = getdate()
		truncate table bronze.erp_cust_az12
		PRINT '>> INSERTING DATA ON TABLE: bronze.erp_cust_az12'
		bulk insert bronze.erp_cust_az12
		from  'C:\sql\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print '>>load duration ' + cast( datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '>> ---------------------';



		set @start_time = getdate()
		truncate table bronze.erp_loc_a101
		PRINT '>> INSERTING DATA ON TABLE: bronze.erp_loc_a101'
		bulk insert bronze.erp_loc_a101
		from  'C:\sql\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print '>>load duration ' + cast( datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '>> ---------------------';



		set @start_time = getdate()
		truncate table bronze.erp_px_cat_glv2
		PRINT '>> INSERTING DATA ON TABLE: bronze.erp_px_cat_glv2'
		bulk insert bronze.erp_px_cat_glv2
		from  'C:\sql\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print '>>load duration ' + cast( datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '>> ---------------------';


		set @batch_end_time = getdate()
		print '>>=======================';
		
		print '>> LOADING BRONZE LAYER COMPLETED'
		print '>> total loading time : ' + cast( datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + ' second'
	
		print '>>=======================';
	END TRY

	BEGIN CATCH
	print 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT ' ERROR MESSAGE' + ERROR_MESSAGE();
	PRINT ' ERROR NUMBER' + CAST(ERROR_NUMBER() AS varchar);
	PRINT ' ERROR NUMBER' + CAST(ERROR_state() AS varchar);
	END CATCH
end




exec bronze.load_bronze
