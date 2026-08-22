/*
===============================================================================
Stored Procedure: Validate Bronze Layer
===============================================================================

Script Purpose:
    This stored procedure validates the data loaded into the Bronze layer.

    It performs basic data quality checks on all Bronze tables, including:
        - Total row count
        - NULL values in important/key columns
        - Execution start time
        - Execution end time
        - Total validation duration
        - Error handling

Validation Checks:
    1. Verify the number of records loaded into each Bronze table.
    2. Check for NULL values in important identifier columns.
    3. Capture the total execution time.
    4. Capture and report SQL errors if validation fails.

Tables Validated:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_loc_a101
        - bronze.erp_cust_az12
        - bronze.erp_px_cat_g1v2

Output:
    - Validation status
    - Table name
    - Total number of rows
    - Number of NULL values in important columns
    - Start time
    - End time
    - Total validation duration
    - Error code and message if validation fails

Usage:
    CALL bronze.validate_bronze();

Important:
    This procedure validates data only. It does not modify or transform
    the Bronze data.

===============================================================================
*/


-- ============================================================================
-- SELECT DATABASE
-- ============================================================================

USE bronze;


-- ============================================================================
-- DROP PROCEDURE IF IT ALREADY EXISTS
-- ============================================================================

DROP PROCEDURE IF EXISTS validate_bronze;


-- ============================================================================
-- CREATE VALIDATION PROCEDURE
-- ============================================================================

DELIMITER $$

CREATE PROCEDURE validate_bronze()
BEGIN


    -- ========================================================================
    -- VARIABLES
    -- ========================================================================

    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration_seconds INT;

    DECLARE error_message TEXT;
    DECLARE error_code INT;


    -- ========================================================================
    -- ERROR HANDLER
    -- MySQL equivalent of TRY...CATCH
    -- Captures SQL errors during the validation process.
    -- ========================================================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        SET end_time = NOW();

        SET duration_seconds =
            TIMESTAMPDIFF(
                SECOND,
                start_time,
                end_time
            );


        -- Retrieve MySQL error information
        GET DIAGNOSTICS CONDITION 1
            error_code = MYSQL_ERRNO,
            error_message = MESSAGE_TEXT;


        -- Return error information
        SELECT
            'Bronze Validation FAILED' AS status,
            error_code AS error_code,
            error_message AS error_message,
            start_time AS start_time,
            end_time AS end_time,
            SEC_TO_TIME(duration_seconds) AS duration;

    END;


    -- ========================================================================
    -- START TIME
    -- ========================================================================

    SET start_time = NOW();


    -- ========================================================================
    -- ROW COUNT & NULL VALIDATION
    -- ========================================================================
    -- Checks:
    --   1. Total rows in each table
    --   2. NULL values in important identifier columns
    -- ========================================================================


    -- CRM Customer
    SELECT
        'crm_cust_info' AS table_name,
        COUNT(*) AS total_rows,
        SUM(
            CASE
                WHEN cst_id IS NULL THEN 1
                ELSE 0
            END
        ) AS null_cst_id
    FROM bronze.crm_cust_info


    UNION ALL


    -- CRM Product
    SELECT
        'crm_prd_info',
        COUNT(*),
        SUM(
            CASE
                WHEN prd_id IS NULL THEN 1
                ELSE 0
            END
        )
    FROM bronze.crm_prd_info


    UNION ALL


    -- CRM Sales Details
    SELECT
        'crm_sales_details',
        COUNT(*),
        SUM(
            CASE
                WHEN sls_ord_num IS NULL THEN 1
                ELSE 0
            END
        )
    FROM bronze.crm_sales_details


    UNION ALL


    -- ERP Location
    SELECT
        'erp_loc_a101',
        COUNT(*),
        SUM(
            CASE
                WHEN cid IS NULL THEN 1
                ELSE 0
            END
        )
    FROM bronze.erp_loc_a101


    UNION ALL


    -- ERP Customer
    SELECT
        'erp_cust_az12',
        COUNT(*),
        SUM(
            CASE
                WHEN cid IS NULL THEN 1
                ELSE 0
            END
        )
    FROM bronze.erp_cust_az12


    UNION ALL


    -- ERP Product Category
    SELECT
        'erp_px_cat_g1v2',
        COUNT(*),
        SUM(
            CASE
                WHEN id IS NULL THEN 1
                ELSE 0
            END
        )
    FROM bronze.erp_px_cat_g1v2;


    -- ========================================================================
    -- END TIME
    -- ========================================================================

    SET end_time = NOW();


    -- Calculate total validation duration in seconds
    SET duration_seconds =
        TIMESTAMPDIFF(
            SECOND,
            start_time,
            end_time
        );


    -- ========================================================================
    -- FINAL SUMMARY
    -- ========================================================================

    SELECT
        'Bronze Layer Validation Completed Successfully'
            AS status,
        start_time,
        end_time,
        SEC_TO_TIME(duration_seconds)
            AS duration;

END$$

DELIMITER ;


-- ============================================================================
-- EXECUTE BRONZE VALIDATION
-- ============================================================================

CALL bronze.validate_bronze();
