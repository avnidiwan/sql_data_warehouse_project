/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/




select * from bronze.crm_cust_info

-- ===errors in ** bronze.crm_cust_info **

--checking the cst_id has duplicates or not
select cst_id, count(*)
from bronze.crm_cust_info
group by cst_id
having count(*)>1


--checking leading and trailing spaces in cst_firstname 
select cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname)


--checking leading and trailing spaces in cst_lastname 
select cst_lastname
from bronze.crm_cust_info
where cst_lastname != trim(cst_lastname)


-- cleaned data inserted into silver.crm_cust_info
select * from silver.crm_cust_info

--================================================
-- === ** bronze.crm_prd_info **
select * from bronze.crm_prd_info

--prd_id is unique, no missing values in prd_key and prd_nm
select prd_id , count(*) from bronze.crm_prd_info
group by prd_id having count(*)>1

select * from bronze.crm_prd_info where prd_key is null or prd_key != trim(prd_key)
select * from bronze.crm_prd_info where prd_nm is null or prd_nm != trim(prd_nm)

--cleaned data inserted into silver.crm_prd_info
select * from silver.crm_prd_info


--========================================
--==== ** bronze.crm_sales_details **

select * from bronze.crm_sales_details
 
 -- no unwanted spaces in 1,2,3 cols
select sls_cust_id
from bronze.crm_sales_details
where sls_cust_id != trim(sls_cust_id)

 
--casting dates from string to date format, apply same logic for col 4,5,6
select 
case 
	when sls_order_dt <= 0 or len(sls_order_dt) != 8
	then null
    else cast(cast(sls_order_dt as nvarchar) as date )
end
from bronze.crm_sales_details


--business logic for col 7,8,9
select sls_sales, sls_quantity,
sls_price from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price or 
      sls_sales <=0  or sls_price <= 0 or sls_sales is null



select * from silver.crm_sales_details

--=====================
-- ** erp_cust_az12 **

 select * from bronze.erp_cust_az12

 select cust_id , count(*) 
 from
 (select substring(cid,9, len(cid)) as cust_id, * from bronze.erp_cust_az12)t
 group by cust_id 
 having cust_id = 39
 

 select *  from silver.erp_cust_az12
 --===================================================

 select * from bronze.erp_loc_a101

 select * from silver.erp_loc_a101

 --===================================================

 select * from bronze.erp_px_cat_glv2

 select * from silver.erp_px_cat_glv2


 --===================================================
