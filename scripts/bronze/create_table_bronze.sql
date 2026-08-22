/*
===============================================================================
DDL Script: Create Bronze Layer Tables
===============================================================================

Script Purpose:
    This script creates the tables required for the Bronze layer of the
    Data Warehouse.

    The Bronze layer stores raw data loaded directly from the source systems
    (CRM and ERP) with minimal or no transformation.

Process:
    1. Drop existing Bronze tables if they already exist.
    2. Recreate the Bronze tables with the required column structures.
    3. These tables will later be populated using the Bronze loading script.

Source Systems:
    - CRM (Customer Relationship Management)
    - ERP (Enterprise Resource Planning)

Target Layer:
    - Bronze

Target Tables:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_loc_a101
        - bronze.erp_cust_az12
        - bronze.erp_px_cat_g1v2

Important:
    - This script only creates the table structures.
    - It does NOT load data into the tables.
    - Existing tables are dropped and recreated.
    - Data loading is handled separately using LOAD DATA LOCAL INFILE.

===============================================================================
*/


-- ============================================================================
-- CRM CUSTOMER INFORMATION
-- ============================================================================
-- Stores raw customer information received from the CRM source system.

DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE
);


-- ============================================================================
-- CRM PRODUCT INFORMATION
-- ============================================================================
-- Stores raw product information received from the CRM source system.

DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);


-- ============================================================================
-- CRM SALES DETAILS
-- ============================================================================
-- Stores raw sales transaction information received from the CRM system.

DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);


-- ============================================================================
-- ERP LOCATION INFORMATION
-- ============================================================================
-- Stores raw customer location/country information received from the ERP
-- source system.

DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid   VARCHAR(50),
    cntry VARCHAR(50)
);


-- ============================================================================
-- ERP CUSTOMER INFORMATION
-- ============================================================================
-- Stores raw customer demographic information received from the ERP system.

DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50)
);


-- ============================================================================
-- ERP PRODUCT CATEGORY INFORMATION
-- ============================================================================
-- Stores raw product category, subcategory, and maintenance information
-- received from the ERP source system.

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50)
);
