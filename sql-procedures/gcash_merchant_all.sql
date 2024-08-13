DROP PROCEDURE IF EXISTS gcash_merchant_all;

DELIMITER //

CREATE PROCEDURE gcash_merchant_all(
    IN merchant_id VARCHAR(36),
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS gcash_report_id,
            ''PRE-TRIAL and BILLABLE'' AS bill_status, 
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

            SUM(`Voucher Price`) AS total_amount,
            `Commission Rate` AS commission_rate,
            ROUND(CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12
                ELSE SUM(`Voucher Price`) * (`Commission Rate` / 100)
            END, 2) AS commission_amount,
            ROUND(CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN (SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12) * 0.12
                ELSE 0.00
            END, 2) AS vat_amount,
            ROUND(CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12
                ELSE SUM(`Voucher Price`) * (`Commission Rate` / 100)
            END
            + CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN (SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12) * 0.12
                ELSE 0.00
            END, 2) AS total_commission_fees
        FROM 
            `gcash_transactions_view`
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN
            `fee` ON `Merchant ID` = fee.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` != ''NOT BILLABLE''
        ');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	        "', v_uuid, '" AS gcash_report_id, 
            ''PRE-TRIAL and BILLABLE'' AS bill_status, 
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

            SUM(`Voucher Price`) AS total_amount,
            `Commission Rate` AS commission_rate,
            ROUND(CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12
                ELSE SUM(`Voucher Price`) * (`Commission Rate` / 100)
            END, 2) AS commission_amount,
            ROUND(CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN (SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12) * 0.12
                ELSE 0.00
            END, 2) AS vat_amount,
            ROUND(CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12
                ELSE SUM(`Voucher Price`) * (`Commission Rate` / 100)
            END
            + CASE
                WHEN fee.commission_type = ''Vat Exc'' THEN (SUM(`Voucher Price`) * (`Commission Rate` / 100) / 1.12) * 0.12
                ELSE 0.00
            END, 2) AS total_commission_fees
        FROM 
            `gcash_transactions_view`
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN
            `fee` ON `Merchant ID` = fee.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` != ''NOT BILLABLE''
        ');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;

    SET @sql_insert1 = CONCAT('INSERT INTO report_history_gcash_body
        (gcash_report_id, item, quantity_redeemed, voucher_value, amount)
        SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
            p.promo_amount AS voucher_value,
	        ROUND(COUNT(`Transaction ID`) * p.promo_amount, 2) AS amount
        FROM 
            `gcash_transactions_view`
        JOIN
            `promo` p ON `Item` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Item`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
            p.promo_amount AS voucher_value,
	        ROUND(COUNT(`Transaction ID`) * p.promo_amount, 2) AS amount
        FROM 
            `gcash_transactions_view`
        JOIN
            `promo` p ON `Item` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Item`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END //

DELIMITER ;
