-- clean and load crm_customer_info:


-- check for NUlls or Duplicates in primary key:
-- Exectation: No results:
select * from bronze.crm_cust_info;

-- check the duplicates and null in the primary key:
select cst_id,
count(*) as duplicates_detect
from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is NULL; 

-- deals with the duplicates and null values:(# use of row_number() to assign no. to each row):
-- main query:
TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    dwh_create_date,
    dwh_update_date
)

SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        ELSE 'n/a'
    END AS cst_marital_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
	
    cst_create_date,

    NOW() AS dwh_create_date,
    NOW() AS dwh_update_date

FROM
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY cst_id
            ORDER BY cst_create_date
        ) AS flag_last

    FROM bronze.crm_cust_info

    WHERE cst_id IS NOT NULL
      AND cst_id != 0

) AS t1

WHERE flag_last = 1;


-- Qulaity check: check for the unwanted space in the string values:
-- used of TRIM(): remove the leading and trailing spaces from a string:
select cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname); # also check for last_name, gender etc

select cst_gndr
from bronze.crm_cust_info
where cst_gndr!= trim(cst_gndr); # no unwanted spaces:

-- Quality checks:  check the consistency of values in low cardinality columns:
select distinct cst_gndr
from bronze.crm_cust_info;

-- Quality check: for the cst-create_date,we have to check the it is not to be string or default, it should be type of date:
-- so yaah, it is date (data type)


-- Quality of silver:
select cst_firstname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname); # no issues after cleaning:

-- check the silver customer table:
select * from silver.crm_cust_info;



-- clean and load crm_prd_info:
select * from bronze.crm_prd_info;
	
-- check the duplicates and NUlls in the primary key:
-- Substring()--> Extracts a specifc part of a string value:
select prd_id,
count(*) as duplicates_detect
from bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is NULL;  # there is no null and duplicates in the product table


-- manipulated the tables, becusse of some changes
DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (

    prd_id       INT,
    cat_id       VARCHAR(50),
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME,

    -- Data Warehouse Metadata
    dwh_create_date DATETIME,
    dwh_update_date DATETIME

);


-- Main Query
TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info
(
    prd_id,
    prd_key,
    cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt,
    dwh_create_date,
    dwh_update_date
)

SELECT
    prd_id,

    SUBSTRING(
        prd_key,
        7,
        LENGTH(prd_key)
    ) AS prd_key,

    REPLACE(
        SUBSTRING(prd_key, 1, 5),
        '-',
        '_'
    ) AS cat_id,

    prd_nm,

    COALESCE(prd_cost, 0) AS prd_cost,

    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        ELSE 'n/a'
    END AS prd_line,

    CAST(prd_start_dt AS DATE) AS prd_start_dt,

    DATE_SUB(
        CAST(
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ) AS DATE
        ),
        INTERVAL 1 DAY
    ) AS prd_end_dt,

    NOW() AS dwh_create_date,

    NOW() AS dwh_update_date

FROM bronze.crm_prd_info;


-- check for  the unwanted spaces in product-name:
-- used of TRIM(): remove the leading and trailing spaces from a string:
select prd_nm
from bronze.crm_prd_info
where prd_nm != trim(prd_nm); # no unwanted spaces:


-- checkfor the Nulls and Negative numbers:
select prd_cost
from bronze.crm_prd_info where prd_cost<0 and prd_cost is null;

-- use of the coalesce to replace the null with the 0:
 
-- Data Standardization and Consistency:
select distinct prd_line
from bronze.crm_prd_info;

-- check for Invalid Data orders:
-- ENd date must not be earliers than the start date:
select prd_id, prd_key, prd_nm, prd_start_dt,
lead(prd_end_dt) over(partition by prd_key order by prd_start_dt) -1 as prd_end_dt_test
from bronze.crm_prd_info;
 
 
-- check the qulaity issues:
select * from silver.crm_prd_info;


-- clean & load crm_sales_details:
select * from bronze.crm_sales_details;

-- ============================================================
-- Create Silver CRM Sales Details Table
-- ============================================================
DROP TABLE IF EXISTS  silver.crm_sales_details;

CREATE TABLE IF NOT EXISTS silver.crm_sales_details
(
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,

    -- Data Warehouse Metadata
    dwh_create_date DATETIME,
    dwh_update_date DATETIME
);

-- main query:
TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price,
    dwh_create_date,
    dwh_update_date
)

select 
sls_ord_num, sls_prd_key, sls_cust_id,
case when sls_order_dt =0 or length(sls_order_dt) !=8 then null
     else CAST(sls_order_dt AS DATE)
end sls_order_dt,
case when sls_ship_dt =0 or length(sls_ship_dt) !=8 then null
     else CAST(sls_ship_dt AS DATE)
end sls_ship_dt,
case when sls_due_dt =0 or length(sls_due_dt) !=8 then null
     else CAST(sls_due_dt AS DATE)
end sls_due_dt,
case when sls_sales<=0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) then (sls_quantity * sls_price)
     else sls_sales
end sls_sales,
sls_quantity,
case when sls_price is null or sls_price=0 then sls_sales / nullif(sls_quantity, 0) # becuase it give infinite, math error ,dividisble is zero, so 1 is mimimum quantity
     when sls_price < 0 then abs(sls_price)
     else sls_price
end sls_price ,
NOW() AS dwh_create_date,
NOW() AS dwh_update_date
    
from bronze.crm_sales_details;

-- show the results:
select * from silver.crm_sales_details;


-- check for the invalid dates:
select nullif(sls_order_dt, 0) as sls_order_dt from bronze.crm_sales_details
where sls_order_dt <=0 or length(sls_order_dt) !=8 or sls_order_dt > 20250101 or  sls_order_dt < 19000101;

-- check that order-date must always be earliers than the shipping-date or due-date:
select * from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt  or sls_order_dt > sls_due_dt; # its means this is in correct order:


-- check the data consistency: between the sales, quantity and prices:
-- sales=quantity * price
-- values must not be null, zero, and negative:
select sls_sales, sls_quantity, sls_price
from bronze.crm_sales_details
where (sls_sales<=0 or sls_quantity<=0 or sls_price<=0) or (sls_sales is null or sls_price is null or sls_quantity is null)
or (sls_sales != sls_quantity * sls_price);

-- Rules:
-- rule1: if sales is negative, zero, or null, derive it using quantity and price.
-- rule2: if price is zero, or null, derive it using sales and quantity.
-- rule3: if price is negative, make it positive.
select sls_sales, sls_quantity, sls_price,
case when sls_sales<=0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) then (sls_quantity * sls_price)
     else sls_sales
end sls_sales,
case when sls_price is null or sls_price=0 then sls_sales / nullif(sls_quantity, 1) # becuase it give infinite, math error ,dividisble is zero, so 1 is mimimum quantity
     when sls_price < 0 then abs(sls_price)
     else sls_price
end sls_price
from bronze.crm_sales_details;


-- clean & load erp_cust_az12:
select  * from bronze.erp_cust_az12;

-- main query:
-- ============================================================
-- Load Data into Silver
-- ============================================================

TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12
(
    cid,
    bdate,
    gen,
    dwh_create_date,
    dwh_update_date
)
select
case when cid like 'NAS%' then substring(cid, 4, length(cid))
	 else cid
end cid,
case when bdate > CURDATE() then null
     else bdate
end bdate, 
case when upper(trim(gen)) in ('F','FEMALE') THEN 'Female'
     when upper(trim(gen)) in ('M','MALE') THEN 'Male'
     else 'n/a'
end gen,
NOW() AS dwh_create_date,
NOW() AS dwh_update_date

from bronze.erp_cust_az12;

-- show the silver table results:
select * from silver.erp_cust_az12;


-- Identify out-of range dates:
select bdate 
from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > CURDATE();  # check for the every old customer or check the birthdate for the future: which is not valid(future birthdays):
 
-- check the consistency problems in the data:
select distinct gen
from bronze.erp_cust_az12; # there is so much inconsistency problems in the data:

	
-- clean & load erp_loc_a101:
select * from bronze.erp_loc_a101;

-- main query:
-- ============================================================
-- Load Data into Silver
-- ============================================================

TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101
(
    cid,
    cntry,
    dwh_create_date,
    dwh_update_date
)
select
replace(cid, '-', '') as cid,
case when lower(trim(cntry)) = 'DE' then 'Germany '
     when lower(trim(cntry)) in ('USA', 'US') then 'United States'
     when trim(cntry) ='' or trim(cntry) is null then 'n/a'
     else trim(cntry)
end cntry,
    NOW() AS dwh_create_date,
    NOW() AS dwh_update_date
from 
bronze.erp_loc_a101;


-- show the silver locatiosn results:
select * from silver.erp_loc_a101;


-- check the consistency & data standardization problems:
select distinct cntry
from bronze.erp_loc_a101;


-- clean & load the erp_px_cat_g1v2:
select * from bronze.erp_px_cat_g1v2;

-- main query:

TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2
(
    id,
    cat,
    subcat,
    maintenance,
    dwh_create_date,
    dwh_update_date
)

SELECT
    id,
    cat,
    subcat,
    maintenance,
    NOW() AS dwh_create_date,
    NOW() AS dwh_update_date

FROM bronze.erp_px_cat_g1v2;

-- show the results of product-category silver layer:
select * from silver.erp_px_cat_g1v2;


-- check the unwanted spaces:
select cat from bronze.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance);

-- check the standardization and consistency issues:
select distinct maintenance
from bronze.erp_px_cat_g1v2;


