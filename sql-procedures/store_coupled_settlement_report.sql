DROP PROCEDURE IF EXISTS generate_store_coupled_report;

DELIMITER //

CREATE PROCEDURE generate_store_coupled_report(
    IN store_id VARCHAR(36),
    IN start_date DATE,
    IN end_date DATE
)
BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_coupled 
        (coupled_report_id, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, leadgen_commission_rate_base, commission_rate, total_commission_fees_1, card_payment_pg_fee, paymaya_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, cwt_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees,total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
                    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), ''-'', DATE_FORMAT("', end_date, '", ''%e, %Y''))
                WHEN DATE_FORMAT("', start_date, '", ''%Y'') = DATE_FORMAT("', end_date, '", ''%Y'') THEN 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), ''-'', DATE_FORMAT("', end_date, '", ''%b %e, %Y''))
                ELSE 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e, %Y''), ''-'', DATE_FORMAT("', end_date, '", ''%b %e, %Y''))
            END AS settlement_period,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            SUM(`Comm Rate Base`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            SUM(`Total Billing`) AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Cart Amount`) AS total_outstanding_amount_2,
	    SUM(`Total Billing`) AS total_commission_fees_2,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_2,
	    10.00 AS bank_fees,
    	    ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2) AS cwt_from_gross_sales,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`Total Billing`) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_transaction_fees,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_pg_fees,
	ROUND(SUM(`Cart Amount`)
	- SUM(`Total Billing`)
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Cart Amount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
            ELSE 0.00
        END
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END,2) AS total_amount_paid_out
        FROM 
            `transaction_summary_view`
	JOIN
        `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Voucher Type` = ''Coupled''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
                    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), ''-'', DATE_FORMAT("', end_date, '", ''%e, %Y''))
                WHEN DATE_FORMAT("', start_date, '", ''%Y'') = DATE_FORMAT("', end_date, '", ''%Y'') THEN 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), ''-'', DATE_FORMAT("', end_date, '", ''%b %e, %Y''))
                ELSE 
                    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e, %Y''), ''-'', DATE_FORMAT("', end_date, '", ''%b %e, %Y''))
            END AS settlement_period,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            SUM(`Comm Rate Base`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            SUM(`Total Billing`) AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Cart Amount`) AS total_outstanding_amount_2,
	    SUM(`Total Billing`) AS total_commission_fees_2,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_2,
	    10.00 AS bank_fees,
    	    ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2) AS cwt_from_gross_sales,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`Total Billing`) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_transaction_fees,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_pg_fees,
	ROUND(SUM(`Cart Amount`)
	- SUM(`Total Billing`)
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Cart Amount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
            ELSE 0.00
        END
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END,2) AS total_amount_paid_out
        FROM 
            `transaction_summary_view`
	JOIN
        `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Voucher Type` = ''Coupled''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END //

DELIMITER ;
