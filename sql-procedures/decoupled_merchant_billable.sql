DROP PROCEDURE IF EXISTS decoupled_merchant_billable;

DELIMITER //

CREATE PROCEDURE decoupled_merchant_billable(
    IN merchant_id VARCHAR(36),
    IN start_date DATE,
    IN end_date DATE
)
BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees, commission_type)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
            ''BILLABLE'' AS bill_status, 
	        `Merchant ID` AS merchant_id, 
            merchant.legal_entity_name AS merchant_business_name, 
            `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
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
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
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
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
            ''BILLABLE'' AS bill_status, 
	        `Merchant ID` AS merchant_id, 
            merchant.legal_entity_name AS merchant_business_name, 
            `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
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
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
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
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END //

DELIMITER ;
