DROP PROCEDURE IF EXISTS coupled_store_all;

DELIMITER //

CREATE PROCEDURE coupled_store_all(
    IN store_id VARCHAR(36),
    IN start_date DATE,
    IN end_date DATE
)
BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_coupled 
        (coupled_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, 
         settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees_1, 
         card_payment_pg_fee, paymaya_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, 
         total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, 
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out, commission_type)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
            ''PRE-TRIAL and BILLABLE'' AS bill_status, 
	        `Store ID` AS store_id, 
            store.legal_entity_name AS store_business_name, 
            `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
            DATE_FORMAT(NOW(), "%M %e, %Y") AS settlement_date,
	        CONCAT("SR#LG", DATE_FORMAT(NOW(), "%Y-%m-%d"), "-", LEFT("', v_uuid, '", 8)) AS settlement_number,
	        CASE
                WHEN DATE_FORMAT("', start_date, '", ''%Y%m'') = DATE_FORMAT("', end_date, '", ''%Y%m'') THEN 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%M %e''), ''-'', DATE_FORMAT("', end_date, '", ''%e, %Y''))
                WHEN DATE_FORMAT("', start_date, '", ''%Y'') = DATE_FORMAT("', end_date, '", ''%Y'') THEN 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%M %e''), ''-'', DATE_FORMAT("', end_date, '", ''%M %e, %Y''))
                ELSE 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%M %e, %Y''), ''-'', DATE_FORMAT("', end_date, '", ''%M %e, %Y''))
            END AS settlement_period,
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base A`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base A`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base A` * (`Commission Rate` / 100)
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` = ''Card Payment'' THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
            SUM(CASE WHEN `Mode of Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Mode of Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Mode of Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            
            SUM(`Cart Amount`) AS total_outstanding_amount_2,
	        SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_2,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_2,
	        CASE WHEN SUM(`Amount to be Disbursed`) <= 0.00 THEN 0.00 ELSE 10.00 END AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * (`CWT Rate` / 100), 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * (`CWT Rate` / 100), 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - CASE WHEN SUM(`Amount to be Disbursed`) <= 0.00 THEN 0.00 ELSE 10.00 END
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * (`CWT Rate` / 100), 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * (`CWT Rate` / 100), 2),
            2) AS total_amount_paid_out,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS coupled_report_id, 
            ''PRE-TRIAL and BILLABLE'' AS bill_status, 
	        `Store ID` AS store_id, 
            store.legal_entity_name AS store_business_name, 
            `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
            DATE_FORMAT(NOW(), "%M %e, %Y") AS settlement_date,
	        CONCAT("SR#LG", DATE_FORMAT(NOW(), "%Y-%m-%d"), "-", LEFT("', v_uuid, '", 8)) AS settlement_number,
	        CASE
                WHEN DATE_FORMAT("', start_date, '", ''%Y%m'') = DATE_FORMAT("', end_date, '", ''%Y%m'') THEN 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%M %e''), ''-'', DATE_FORMAT("', end_date, '", ''%e, %Y''))
                WHEN DATE_FORMAT("', start_date, '", ''%Y'') = DATE_FORMAT("', end_date, '", ''%Y'') THEN 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%M %e''), ''-'', DATE_FORMAT("', end_date, '", ''%M %e, %Y''))
                ELSE 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%M %e, %Y''), ''-'', DATE_FORMAT("', end_date, '", ''%M %e, %Y''))
            END AS settlement_period,
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base A`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base A`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base A` * (`Commission Rate` / 100)
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` = ''Card Payment'' THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
            SUM(CASE WHEN `Mode of Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Mode of Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Mode of Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            
            SUM(`Cart Amount`) AS total_outstanding_amount_2,
	        SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_2,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_2,
	        CASE WHEN SUM(`Amount to be Disbursed`) <= 0.00 THEN 0.00 ELSE 10.00 END AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * (`CWT Rate` / 100), 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * (`CWT Rate` / 100), 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - CASE WHEN SUM(`Amount to be Disbursed`) <= 0.00 THEN 0.00 ELSE 10.00 END
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * (`CWT Rate` / 100), 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * (`CWT Rate` / 100), 2),
            2) AS total_amount_paid_out,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
        WHERE
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END //

DELIMITER ;
