-- integrate the data for customers:(dimensions table):

CREATE OR REPLACE VIEW gold.dm_customers AS
select
row_number() over (order by cst_id) as customer_key, # this is the key, or unique identifier used a  primary key in the datawarehouse: 
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name, 
ci.cst_marital_status as marital_status,
case when ci.cst_gndr !='n/a' then ci.cst_gndr
	else coalesce(ca.gen, 'n/a')
end gender,
ci.cst_create_date as create_date,
ca.bdate as birth_date, 
la.cntry as country
from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ci.cst_key= ca.cid
left join silver.erp_loc_a101 as la
on ci.cst_key=la.cid;


-- check the data:
select * from silver.crm_cust_info;
select * from silver.erp_loc_a101;

select * from silver.erp_cust_az12;

-- check that there is two column after data integrtion:
select
ci.cst_gndr, ca.gen,
case when ci.cst_gndr !='n/a' then ci.cst_gndr
	else coalesce(ca.gen, 'n/a')
end new_gen
from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ci.cst_key= ca.cid
left join silver.erp_loc_a101 as la
on ci.cst_key=la.cid;


-- check the gold layer table customers object:
select * from gold.dm_customers;

-- Quality check the gold table:
select distinct gender
from gold.dm_customers; # no issues with the data;


-- integrate the data for products: ((dimensions table)
-- here is the product end date is the historical date of the product, and we want only this through nulls:
CREATE OR REPLACE VIEW gold.dm_products  AS
select
row_number() over(order by pn.prd_start_dt,pn.prd_key) as product_key,  # surrogate key for the products table(data-warehouse):
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.prd_line as product_line,
pn.prd_cost as cost,
pn.prd_start_dt as start_date,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance as maintenance
from silver.crm_prd_info as pn
left join silver.erp_px_cat_g1v2 as pc
on  pn.cat_id= pc.id
where pn.prd_end_dt is null; # filter out all the histotrical data (through nulls):

-- check the gold products object table:
select * from gold.dm_products;

-- check the data
select * from silver.crm_prd_info;  # cat_id
select * from  silver.erp_px_cat_g1v2; # id


-- integrated the data for sales:(facts table):
-- joins on the basis of the dimensions primary keyo of products, and customers:
-- but write the columns of the surrogate keys of the dimensions table after joining: (give info about the dimensions tables):

CREATE OR REPLACE VIEW gold.facts_sales  AS
select
sd.sls_ord_num order_number,
pd.product_key as product_key,
cs.customer_key as customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as ship_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount, 
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd 
left join gold.dm_customers as cs
on sd.sls_cust_id=cs.customer_id
left join gold.dm_products as pd
on sd.sls_prd_key=pd.product_number;

-- show the gold table of facts.sales table(join the fact with the multiples dimensions):
select * from gold.facts_sales;

-- check the foreign key integrity:(Dimensions):
select * 
from gold.facts_sales as f
left join gold.dm_customers as c 
on c.customer_key=f.customer_key
left join gold.dm_products as pd
on pd.product_key=f.product_key	
where pd.product_key is null; # no issues with integrity of keys:


-- show all the gold layer business ready tables:
select * from gold.dm_customers;
select * from gold.dm_products;
select * from gold.facts_sales;
