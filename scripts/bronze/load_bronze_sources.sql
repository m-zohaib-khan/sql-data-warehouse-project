/*
===============================================================================
DDL/ETL Script: Load Bronze Layer
===============================================================================

Script Purpose:
    This script loads raw data from the CRM and ERP source CSV files
    into the Bronze layer of the Data Warehouse.

    The Bronze layer stores the data in its raw form with minimal
    transformation. Each target table is truncated before loading
    the latest data from its corresponding source CSV file.

Process:
    1. Truncate existing Bronze tables.
    2. Load raw data from CRM source CSV files.
    3. Load raw data from ERP source CSV files.
    4. Verify the loaded data and row counts.

Source Systems:
    - CRM
    - ERP

Target Layer:
    - Bronze

Target Tables:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_loc_a101
    - bronze.erp_cust_az12
    - bronze.erp_px_cat_g1v2

Important:
    - The first row of each CSV file contains column headers and is
      skipped using IGNORE 1 ROWS.
    - LOAD DATA LOCAL INFILE requires LOCAL INFILE to be enabled
      on both the MySQL server and client (MySQL Workbench).
    - Existing Bronze data is completely removed using TRUNCATE
      before each load.

===============================================================================
*/


-- ============================================================================
-- CRM CUSTOMER
-- ============================================================================

TRUNCATE TABLE bronze.crm_cust_info;

LOAD DATA LOCAL INFILE
'D:/SQl-for-data-science/SQl-Modern-Data-Warehouse-Project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- ============================================================================
-- CRM PRODUCT
-- ============================================================================

TRUNCATE TABLE bronze.crm_prd_info;

LOAD DATA LOCAL INFILE
'D:/SQl-for-data-science/SQl-Modern-Data-Warehouse-Project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- ============================================================================
-- CRM SALES DETAILS
-- ============================================================================

TRUNCATE TABLE bronze.crm_sales_details;

LOAD DATA LOCAL INFILE
'D:/SQl-for-data-science/SQl-Modern-Data-Warehouse-Project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- ============================================================================
-- ERP LOCATION
-- ============================================================================

TRUNCATE TABLE bronze.erp_loc_a101;

LOAD DATA LOCAL INFILE
'D:/SQl-for-data-science/SQl-Modern-Data-Warehouse-Project/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- ============================================================================
-- ERP CUSTOMER
-- ============================================================================

TRUNCATE TABLE bronze.erp_cust_az12;

LOAD DATA LOCAL INFILE
'D:/SQl-for-data-science/SQl-Modern-Data-Warehouse-Project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- ============================================================================
-- ERP PRODUCT CATEGORY
-- ============================================================================

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

LOAD DATA LOCAL INFILE
'D:/SQl-for-data-science/SQl-Modern-Data-Warehouse-Project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- ============================================================================
-- DATA VALIDATION / VERIFICATION
-- ============================================================================

-- CRM Customer
SELECT * FROM bronze.crm_cust_info;

SELECT COUNT(*) AS total_rows
FROM bronze.crm_cust_info;


-- CRM Product
SELECT * FROM bronze.crm_prd_info;


-- CRM Sales Details
SELECT * FROM bronze.crm_sales_details;


-- ERP Location
SELECT * FROM bronze.erp_loc_a101;


-- ERP Customer
SELECT * FROM bronze.erp_cust_az12;


-- ERP Product Category
SELECT * FROM bronze.erp_px_cat_g1v2;
