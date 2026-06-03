/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/



IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
select 
	row_number() over(order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	l.CNTRY as country,
	ci.cst_marital_status as marital_status,
	case
		when ci.cst_gndr != 'n\a' then ci.cst_gndr
		else coalesce(c.gen, 'n\a')
	end as gender,
	c.BDATE  as birth_date,
	ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 c
on ci.cst_key = c.cid
left join silver.erp_loc_a101 l
on ci.cst_key = l.CID;

--==================================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
select
	ROW_NUMBER() over(order by prd.prd_start_dt, prd.prd_key) as product_key,
	prd.prd_id as product_id,
	prd.prd_key as product_number,
	prd.prd_nm as product_name,
	prd.cat_id as category_id,
	cat.CAT as category,
	cat.SUBCAT as subcategory,
	cat.MAINTENANCE as maintenance,
	prd.prd_cost as product_cost,
	prd.prd_line as product_line,
	prd.prd_start_dt as start_date
from silver.crm_prd_info prd
left join silver.erp_px_cat_glv2 cat
on prd.cat_id = cat.ID
where prd_end_dt is null;


--==================================================================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
select 
	s.sls_ord_num as order_number,
	p.product_key,
	c.customer_key,
	s.sls_order_dt as order_date,
	s.sls_ship_dt as ship_date,
	s.sls_due_dt as due_date,
	s.sls_sales as sales_amount,
	s.sls_quantity as quantity,
	s.sls_price as price
from silver.crm_sales_details s
left join gold.dim_products p
on s.sls_prd_key = p.product_number
left join gold.dim_customers c
on c.customer_id = s.sls_cust_id


--=========================================================================================================================
