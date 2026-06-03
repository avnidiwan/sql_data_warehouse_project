/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/




exec silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver as
BEGIN
   DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY

	SET @batch_start_time = getdate()
	    PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';


		-- ** crm_cst_info **   clean data from bronze layer and then inserted it into silver layer
		SET @start_time = getdate()
		TRUNCATE TABLE silver.crm_cust_info
		insert into silver.crm_cust_info(
			cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
		select cst_id,
		cst_key,
		trim(cst_firstname) cst_firstname,
		trim(cst_lastname) cst_lastname,
		case when upper(trim(cst_marital_status)) = 'S' then 'Single'
			 when upper(trim(cst_marital_status)) = 'M' then 'Married'
			 else 'n\a'
		end as cst_marital_statue
		,
		case
			when upper(trim(cst_gndr)) = 'M' then 'Male'
			when upper(trim(cst_gndr)) = 'F' then 'Female'
			else 'n\a'
		end as cst_gndr
		,
		cst_create_date
		from 
		(
			select *,
			row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_cust_info
			where cst_id is not null
		)t
		where flag_last = 1
		SET @end_time = getdate()
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		--======================================================================================================


		-- ** crm_prd_info **  clean data from bronze layer and then inserted it into silver layer

		SET @start_time = getdate()
		TRUNCATE TABLE silver.crm_prd_info
		INSERT INTO silver.crm_prd_info (
					prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt
				)
		select prd_id, 
		replace(substring(prd_key,1,5),'-', '_') as cat_id, 
		substring(prd_key, 7, len(prd_key)) as prd_key, 
		prd_nm, 
		isnull(prd_cost,0) as prd_cost,
		case upper(trim(prd_line)) 
			when 'S' then 'other sales'
			when 'M' then 'Mountain'
			when 'R' then 'Road'
			when 'T' then 'Touring'
			else 'n\a'
		end
		,
		cast(prd_start_dt as date) as prd_start_dt,
		CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt

		from bronze.crm_prd_info
		SET @end_time = getdate()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		--====================================================================================================

		-- ** crm_sales_details ** 

		SET @start_time = getdate()
		TRUNCATE TABLE silver.crm_sales_details
		insert into silver.crm_sales_details(
			sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
		)
		select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case 
				when sls_order_dt <= 0 or len(sls_order_dt) != 8
				then null
				else cast(cast(sls_order_dt as nvarchar) as date )
			end
			,
			case 
				when sls_ship_dt <= 0 or len(sls_ship_dt) != 8
				then null
				else cast(cast(sls_ship_dt as nvarchar) as date )
			end
			,
			case 
				when sls_due_dt <= 0 or len(sls_due_dt) != 8
				then null
				else cast(cast(sls_due_dt as nvarchar) as date )
			end
			,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, 
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price  
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = getdate()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		--=======================================================================================================

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

 
		-- ==== ** erp_cust_az12 **

		SET @start_time = getdate()
		TRUNCATE TABLE silver.erp_cust_az12
		INSERT INTO silver.erp_cust_az12 (
			cid,bdate,gen
		)
		SELECT
		CASE
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
			ELSE cid
		END AS cid, 
		CASE
			WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate, 
		CASE
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			ELSE 'n/a'
		END AS gen 
		FROM bronze.erp_cust_az12;
		SET @end_time = getdate()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		--=======================================================================================================

		--==== ** erp_loc_a101 **

		SET @start_time = getdate()
		TRUNCATE TABLE silver.erp_loc_a101
		INSERT INTO silver.erp_loc_a101 (
			cid,cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid, 
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry 
		FROM bronze.erp_loc_a101;
		SET @end_time = getdate()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		--=======================================================================================================

		--==== ** erp_px_cat_glv2 ** 

		SET @start_time = getdate()
		TRUNCATE TABLE silver.erp_px_cat_glv2 
		INSERT INTO silver.erp_px_cat_glv2 (
			id,cat,subcat,maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_glv2;
		SET @end_time = getdate()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
		--======================================================================================================
		END TRY
		BEGIN CATCH
		print 'ERROR OCCURED DURING LOADING BRONZE LAYER'
    	PRINT ' ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT ' ERROR NUMBER' + CAST(ERROR_NUMBER() AS varchar);
		PRINT ' ERROR NUMBER' + CAST(ERROR_state() AS varchar);
		END CATCH
END
