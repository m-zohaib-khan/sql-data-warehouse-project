/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================

Script Purpose:
    This script creates the tables required for the Silver layer of the
    Data Warehouse.

    The Silver layer contains cleaned, standardized, and transformed data
    coming from the Bronze layer.

    Unlike the Bronze layer, Silver tables may contain:
        - Cleaned values
        - Standardized formats
        - Corrected data types
        - Derived/transformed columns
        - Data Warehouse metadata

Process:
    1. Drop existing Silver tables if they already exist.
    2. Recreate the Silver tables.
    3. Add Data Warehouse metadata columns to every table.

Source Layer:
    - Bronze

Target Layer:
    - Silver

Metadata Columns:
    - dwh_create_date
        Records when the row was initially loaded into the Silver layer.

    - dwh_update_date
        Records when the row was last updated in the Silver layer.

Tables:
    CRM:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

    ERP:
        - silver.erp_loc_a101
        - silver.erp_cust_az12
        - silver.erp_px_cat_g1v2

Important:
    Silver tables are intended for cleaned and standardized data.
    Transformations should be performed while loading data from Bronze
    into Silver.

===============================================================================
*/


-- ============================================================================
-- CRM CUSTOMER INFORMATION
-- ============================================================================
-- Stores cleaned and standardized customer information.

DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (

    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE,

    -- Data Warehouse Metadata
    dwh_create_date    DATETIME,
    dwh_update_date    DATETIME

);


-- ============================================================================
-- CRM PRODUCT INFORMATION
-- ============================================================================
-- Stores cleaned and standardized product information.

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (

    prd_id       INT,
    cat_id       varchar(50),
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


-- ============================================================================
-- CRM SALES DETAILS
-- ============================================================================
-- Stores cleaned and standardized sales transaction information.

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (

    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt date,
    sls_ship_dt  date,
    sls_due_dt   date,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,

    -- Data Warehouse Metadata
    dwh_create_date DATETIME,
    dwh_update_date DATETIME

);


-- ============================================================================
-- ERP LOCATION INFORMATION
-- ============================================================================
-- Stores cleaned and standardized customer location information.

DROP TABLE IF EXISTS silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (

    cid   VARCHAR(50),
    cntry VARCHAR(50),

    -- Data Warehouse Metadata
    dwh_create_date DATETIME,
    dwh_update_date DATETIME

);


-- ============================================================================
-- ERP CUSTOMER INFORMATION
-- ============================================================================
-- Stores cleaned and standardized customer demographic information.

DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (

    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50),

    -- Data Warehouse Metadata
    dwh_create_date DATETIME,
    dwh_update_date DATETIME

);


-- ============================================================================
-- ERP PRODUCT CATEGORY INFORMATION
-- ============================================================================
-- Stores cleaned and standardized product category information.

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (

    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50),

    -- Data Warehouse Metadata
    dwh_create_date DATETIME,
    dwh_update_date DATETIME

);
