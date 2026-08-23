-- ============================================================
-- SILVER LAYER VALIDATION PROCEDURE
-- ============================================================

USE silver;

DROP PROCEDURE IF EXISTS validate_silver;

DELIMITER $$

CREATE PROCEDURE validate_silver()
BEGIN

    -- ============================================================
    -- VARIABLES
    -- ============================================================

    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration_seconds INT;

    DECLARE error_message TEXT;
    DECLARE error_code INT;


    -- ============================================================
    -- ERROR HANDLER
    -- ============================================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        SET end_time = NOW();

        SET duration_seconds =
            TIMESTAMPDIFF(
                SECOND,
                start_time,
                end_time
            );

        GET DIAGNOSTICS CONDITION 1
            error_code = MYSQL_ERRNO,
            error_message = MESSAGE_TEXT;

        SELECT
            '================================================' AS message;

        SELECT
            'Silver Validation FAILED' AS status,
            error_code AS error_code,
            error_message AS error_message,
            start_time AS start_time,
            end_time AS end_time,
            SEC_TO_TIME(duration_seconds) AS duration;

    END;


    -- ============================================================
    -- START TIME
    -- ============================================================

    SET start_time = NOW();

    SELECT
        '================================================' AS message;

    SELECT
        'STARTING SILVER LAYER VALIDATION' AS message;


    -- ============================================================
    -- 1. CRM CUSTOMER VALIDATION
    -- ============================================================

    SELECT
        '------------------------------------------------' AS message;

    SELECT
        '1. CRM CUSTOMER VALIDATION' AS message;

    SELECT
        'crm_cust_info' AS table_name,
        COUNT(*) AS total_rows,

        SUM(
            CASE
                WHEN cst_id IS NULL THEN 1
                ELSE 0
            END
        ) AS null_cst_id,

        SUM(
            CASE
                WHEN cst_key IS NULL
                     OR TRIM(cst_key) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_cst_key,

        SUM(
            CASE
                WHEN cst_firstname IS NULL
                     OR TRIM(cst_firstname) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_firstname,

        SUM(
            CASE
                WHEN cst_lastname IS NULL
                     OR TRIM(cst_lastname) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_lastname

    FROM silver.crm_cust_info;


    -- ============================================================
    -- 2. CRM PRODUCT VALIDATION
    -- ============================================================

    SELECT
        '------------------------------------------------' AS message;

    SELECT
        '2. CRM PRODUCT VALIDATION' AS message;

    SELECT
        'crm_prd_info' AS table_name,
        COUNT(*) AS total_rows,

        SUM(
            CASE
                WHEN prd_id IS NULL THEN 1
                ELSE 0
            END
        ) AS null_prd_id,

        SUM(
            CASE
                WHEN prd_key IS NULL
                     OR TRIM(prd_key) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_prd_key,

        SUM(
            CASE
                WHEN cat_id IS NULL
                     OR TRIM(cat_id) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_cat_id,

        SUM(
            CASE
                WHEN prd_nm IS NULL
                     OR TRIM(prd_nm) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_product_name

    FROM silver.crm_prd_info;


    -- ============================================================
    -- 3. CRM SALES DETAILS VALIDATION
    -- ============================================================

    SELECT
        '------------------------------------------------' AS message;

    SELECT
        '3. CRM SALES DETAILS VALIDATION' AS message;

    SELECT
        'crm_sales_details' AS table_name,
        COUNT(*) AS total_rows,

        SUM(
            CASE
                WHEN sls_ord_num IS NULL
                     OR TRIM(sls_ord_num) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_order_number,

        SUM(
            CASE
                WHEN sls_prd_key IS NULL
                     OR TRIM(sls_prd_key) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_product_key,

        SUM(
            CASE
                WHEN sls_cust_id IS NULL
                THEN 1
                ELSE 0
            END
        ) AS null_customer_id,

        SUM(
            CASE
                WHEN sls_order_dt IS NULL
                THEN 1
                ELSE 0
            END
        ) AS null_order_date,

        SUM(
            CASE
                WHEN sls_sales IS NULL
                THEN 1
                ELSE 0
            END
        ) AS null_sales,

        SUM(
            CASE
                WHEN sls_quantity IS NULL
                     OR sls_quantity <= 0
                THEN 1
                ELSE 0
            END
        ) AS invalid_quantity,

        SUM(
            CASE
                WHEN sls_price IS NULL
                     OR sls_price <= 0
                THEN 1
                ELSE 0
            END
        ) AS invalid_price

    FROM silver.crm_sales_details;


    -- ============================================================
    -- 4. ERP CUSTOMER VALIDATION
    -- ============================================================

    SELECT
        '------------------------------------------------' AS message;

    SELECT
        '4. ERP CUSTOMER VALIDATION' AS message;

    SELECT
        'erp_cust_az12' AS table_name,
        COUNT(*) AS total_rows,

        SUM(
            CASE
                WHEN cid IS NULL
                     OR TRIM(cid) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_customer_id,

        SUM(
            CASE
                WHEN bdate IS NULL
                THEN 1
                ELSE 0
            END
        ) AS null_birthdate,

        SUM(
            CASE
                WHEN gen IS NULL
                     OR TRIM(gen) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_gender

    FROM silver.erp_cust_az12;


    -- ============================================================
    -- 5. ERP LOCATION VALIDATION
    -- ============================================================

    SELECT
        '------------------------------------------------' AS message;

    SELECT
        '5. ERP LOCATION VALIDATION' AS message;

    SELECT
        'erp_loc_a101' AS table_name,
        COUNT(*) AS total_rows,

        SUM(
            CASE
                WHEN cid IS NULL
                     OR TRIM(cid) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_customer_id,

        SUM(
            CASE
                WHEN cntry IS NULL
                     OR TRIM(cntry) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_country

    FROM silver.erp_loc_a101;


    -- ============================================================
    -- 6. ERP PRODUCT CATEGORY VALIDATION
    -- ============================================================

    SELECT
        '------------------------------------------------' AS message;

    SELECT
        '6. ERP PRODUCT CATEGORY VALIDATION' AS message;

    SELECT
        'erp_px_cat_g1v2' AS table_name,
        COUNT(*) AS total_rows,

        SUM(
            CASE
                WHEN id IS NULL
                     OR TRIM(id) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_id,

        SUM(
            CASE
                WHEN cat IS NULL
                     OR TRIM(cat) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_category,

        SUM(
            CASE
                WHEN subcat IS NULL
                     OR TRIM(subcat) = ''
                THEN 1
                ELSE 0
            END
        ) AS null_subcategory

    FROM silver.erp_px_cat_g1v2;


    -- ============================================================
    -- END TIME
    -- ============================================================

    SET end_time = NOW();

    SET duration_seconds =
        TIMESTAMPDIFF(
            SECOND,
            start_time,
            end_time
        );


    -- ============================================================
    -- FINAL SUMMARY
    -- ============================================================

    SELECT
        '================================================' AS message;

    SELECT
        'Silver Layer Validation Completed Successfully'
            AS status,
        start_time AS start_time,
        end_time AS end_time,
        SEC_TO_TIME(duration_seconds) AS duration;

    SELECT
        '================================================' AS message;

END$$

DELIMITER ;

CALL silver.validate_silver();
