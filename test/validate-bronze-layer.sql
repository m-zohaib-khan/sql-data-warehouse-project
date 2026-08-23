USE bronze;

DROP PROCEDURE IF EXISTS validate_bronze;

DELIMITER $$

CREATE PROCEDURE validate_bronze()
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
            'Bronze Validation FAILED' AS status,
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


    -- ============================================================
    -- ROW COUNT VALIDATION
    -- ============================================================
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
        'Bronze Layer Validation Completed Successfully'
            AS status,
        start_time,
        end_time,
        SEC_TO_TIME(duration_seconds)
            AS duration;

END$$

DELIMITER ;


CALL bronze.validate_bronze();

