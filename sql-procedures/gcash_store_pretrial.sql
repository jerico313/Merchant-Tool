DROP PROCEDURE IF EXISTS gcash_store_pretrial;

DELIMITER //

CREATE PROCEDURE gcash_store_pretrial(
    IN store_id VARCHAR(36),
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
     (gcash_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate, commission_amount, vat_amount, total_commission_fees)
     SELECT 
         "', v_uuid, '" AS gcash_report_id,
         ''PRE-TRIAL'' AS bill_status, 
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
         `store` ON `Store ID` = store.`store_id`
     JOIN
         `merchant` ON merchant.`merchant_id` = store.`merchant_id`
     JOIN
         `fee` ON fee.`merchant_id` = merchant.`merchant_id`
     WHERE 
         `Store ID` = "', store_id, '"
         AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
         AND `Bill Status` = ''PRE-TRIAL''
     GROUP BY `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
         "', v_uuid, '" AS gcash_report_id,
         ''PRE-TRIAL'' AS bill_status, 
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
         `store` ON `Store ID` = store.`store_id`
     JOIN
         `merchant` ON merchant.`merchant_id` = store.`merchant_id`
     JOIN
         `fee` ON fee.`merchant_id` = merchant.`merchant_id`
     WHERE 
         `Store ID` = "', store_id, '"
         AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
         AND `Bill Status` = ''PRE-TRIAL''
     GROUP BY `Store ID`');

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
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` = ''PRE-TRIAL''
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
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Item`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END //

DELIMITER ;

