-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 24, 2024 at 09:33 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `leadgen_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_merchant_coupled_report` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_coupled 
        (coupled_report_id, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, leadgen_commission_rate_base, commission_rate, total_commission_fees_1, card_payment_pg_fee, paymaya_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, cwt_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees,total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
	    `Merchant ID` AS merchant_id, 
            merchant.legal_entity_name AS merchant_business_name, 
            `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
            DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_outstanding_amount_1,
            SUM(`Net Amount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            SUM(`Total Billing`) AS total_commission_fees_1,

            SUM(CASE WHEN `Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,

            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Net Amount`) AS total_outstanding_amount_2,
	    SUM(`Total Billing`) AS total_commission_fees_2,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_2,
	    10.00 AS bank_fees,
    	    ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2) AS cwt_from_gross_sales,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_transaction_fees,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_pg_fees,
	ROUND(SUM(`Net Amount`)
	- SUM(`Total Billing`)
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`Total Billing`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END,2) AS total_amount_paid_out
        FROM 
            `transaction_summary_view`
	JOIN
        `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Voucher Type` = ''Coupled''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
        "', v_uuid, '" AS coupled_report_id,
	`Merchant ID` AS merchant_id, 
        merchant.legal_entity_name AS merchant_business_name, 
        `Merchant Name` AS merchant_brand_name,
        merchant.business_address AS business_address,
        "', start_date, '" AS settlement_period_start,
        "', end_date, '" AS settlement_period_end,
        DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
        CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
        CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
        COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_outstanding_amount_1,
            SUM(`Net Amount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            SUM(`Total Billing`) AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Net Amount`) AS total_outstanding_amount_2,
	    SUM(`Total Billing`) AS total_commission_fees_2,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_2,
	    10.00 AS bank_fees,
    	    ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2) AS cwt_from_gross_sales,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_transaction_fees,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
                ELSE 0.00
            END AS cwt_from_pg_fees,
	ROUND(SUM(`Net Amount`)
	- SUM(`Total Billing`)
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`Total Billing`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END,2) AS total_amount_paid_out
    FROM 
        `transaction_summary_view` tsv
    JOIN
        `merchant` ON `Merchant ID` = merchant.`merchant_id`
    WHERE 
        `Merchant ID` = "', merchant_id, '"
        AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	AND `Voucher Type` = ''Coupled''
    GROUP BY 
        `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_merchant_decoupled_report` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled
        (decoupled_report_id, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_successful_orders, total_gross_sales, total_discount, total_net_sales, leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id,
            `Merchant ID` AS merchant_id,
            merchant.legal_entity_name AS merchant_business_name,
	    `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
            
	    COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                    ELSE 0
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_billable,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Voucher Type` = ''Decoupled''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	    "', v_uuid, '" AS decoupled_report_id, 
            `Merchant ID` AS merchant_id,
            merchant.legal_entity_name AS merchant_business_name,
	    `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                    ELSE 0
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_billable,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Voucher Type` = ''Decoupled''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_merchant_gcash_report` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS gcash_report_id,
            `Merchant ID` AS merchant_id,
            merchant.legal_entity_name AS merchant_business_name,
	    `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
            DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
	    SUM(`Net Amount`) AS total_amount,
	    `Commission Rate` AS commission_rate,
	    SUM(`Commission Amount`) AS commission_amount,
	    SUM(`Commission Amount`) * 0.12 AS vat_amount,
	    SUM(`Total Billing`) AS total_commission_fees
        FROM 
            `transaction_summary_view`
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	    "', v_uuid, '" AS gcash_report_id, 
            `Merchant ID` AS merchant_id,
            merchant.legal_entity_name AS merchant_business_name,
	    `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
	    SUM(`Net Amount`) AS total_amount,
	    `Commission Rate` AS commission_rate,
	    SUM(`Commission Amount`) AS commission_amount,
	    SUM(`Commission Amount`) * 0.12 AS vat_amount,
	    SUM(`Total Billing`) AS total_commission_fees
        FROM 
            `transaction_summary_view`
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;

    SET @sql_insert1 = CONCAT('INSERT INTO report_history_gcash_body
        (gcash_report_id, item, quantity_redeemed, net_amount)
        SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	    SUM(`Net Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	    SUM(`Net Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_store_coupled_report` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

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

	    DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_outstanding_amount_1,
            SUM(`Net Amount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            SUM(`Total Billing`) AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Net Amount`) AS total_outstanding_amount_2,
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
	ROUND(SUM(`Net Amount`)
	- SUM(`Total Billing`)
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Net Amount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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

	    DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_outstanding_amount_1,
            SUM(`Net Amount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            SUM(`Total Billing`) AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Net Amount`) AS total_outstanding_amount_2,
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
	ROUND(SUM(`Net Amount`)
	- SUM(`Total Billing`)
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Net Amount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_store_decoupled_report` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled
        (decoupled_report_id, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_successful_orders, total_gross_sales, total_discount, total_net_sales, leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id,
            `Store ID` AS store_id,
            store.legal_entity_name AS store_business_name,
	    `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
            
	    COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                    ELSE 0
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_billable,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Voucher Type` = ''Decoupled''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	    "', v_uuid, '" AS decoupled_report_id, 
            `Store ID` AS store_id,
            store.legal_entity_name AS store_business_name,
	    `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Net Amount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                    ELSE 0
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Net Amount`
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_billable,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                    ELSE 0
            END) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Voucher Type` = ''Decoupled''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_store_gcash_report` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS gcash_report_id,
            `Store ID` AS store_id,
            store.legal_entity_name AS store_business_name,
	    `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
            DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
	    SUM(`Net Amount`) AS total_amount,
	    `Commission Rate` AS commission_rate,
	    SUM(`Commission Amount`) AS commission_amount,
	    SUM(`Commission Amount`) * 0.12 AS vat_amount,
	    SUM(`Total Billing`) AS total_commission_fees
        FROM 
            `transaction_summary_view`
        JOIN
            `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	    "', v_uuid, '" AS gcash_report_id, 
            `Store ID` AS store_id,
            store.legal_entity_name AS store_business_name,
	    `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
            DATE_FORMAT(NOW(), "%b %e, %Y") AS settlement_date,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 8)) AS settlement_number,
	    CONCAT(DATE_FORMAT("', start_date, '", ''%b %e''), '' - '', DATE_FORMAT("', end_date, '", ''%b %e, %Y'')) AS settlement_period,
	    SUM(`Net Amount`) AS total_amount,
	    `Commission Rate` AS commission_rate,
	    SUM(`Commission Amount`) AS commission_amount,
	    SUM(`Commission Amount`) * 0.12 AS vat_amount,
	    SUM(`Total Billing`) AS total_commission_fees
        FROM 
            `transaction_summary_view`
        JOIN
            `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;

    SET @sql_insert1 = CONCAT('INSERT INTO report_history_gcash_body
        (gcash_report_id, item, quantity_redeemed, net_amount)
        SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	    SUM(`Net Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	    SUM(`Net Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Payment` = ''gcash''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `activity_history`
--

CREATE TABLE `activity_history` (
  `activity_id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `table_name` varchar(50) NOT NULL,
  `table_id` varchar(36) NOT NULL,
  `activity_type` enum('Add','Update','Delete','Login') NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `activity_history`
--

INSERT INTO `activity_history` (`activity_id`, `user_id`, `table_name`, `table_id`, `activity_type`, `description`, `created_at`, `updated_at`) VALUES
('016bdbbe-2eb7-11ef-abc9-48e7dad87c24', NULL, 'transaction', 'a6673ec0-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Transaction record updated\npromo_id: 8504f541-2d50-11ef-a4d2-48e7dad87c24 -> GCA5H', '2024-06-20 03:41:40', '2024-06-20 03:41:40'),
('0743f147-31f8-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', '07430231-31f8-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-07430231\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:04:41', '2024-06-24 07:04:41'),
('07461dba-31f8-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '07430231-31f8-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 07430231-31f8-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 15570.00\namount: 31140.00', '2024-06-24 07:04:41', '2024-06-24 07:04:41'),
('07462182-31f8-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '07430231-31f8-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 07430231-31f8-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00\namount: 1600.00', '2024-06-24 07:04:41', '2024-06-24 07:04:41'),
('08785777-2795-11ef-a232-0a002700000d', NULL, 'user', '08783957-2795-11ef-a232-0a002700000d', 'Add', 'User record added\nemail_address: sample@email.com\npassword: sample123\nname: Sample User\ntype: Admin\nstatus: ', '2024-06-11 01:50:51', '2024-06-11 01:50:51'),
('0bc19da2-2eb8-11ef-abc9-48e7dad87c24', NULL, 'transaction', 'e881c2e7-224a-11ef-b01f-48e7dad87c24', 'Update', 'Transaction record updated', '2024-06-20 03:49:07', '2024-06-20 03:49:07'),
('0d693fae-31f4-11ef-a30f-0a002700000d', NULL, 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Promo record updated\nvoucher_type: Coupled -> Decoupled', '2024-06-24 06:36:13', '2024-06-24 06:36:13'),
('157b709f-31f4-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '157b5bac-31f4-11ef-a30f-0a002700000d', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-157ab0f9\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 179.20\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-24 06:36:27', '2024-06-24 06:36:27'),
('1c3ad6cf-31f2-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '1c3abfde-31f2-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-1c39d6\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 47.24\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26548.66', '2024-06-24 06:22:19', '2024-06-24 06:22:19'),
('24c431d2-2d47-11ef-a4d2-48e7dad87c24', NULL, 'store', '24c4128f-2d47-11ef-a4d2-48e7dad87c24', 'Add', 'Store record added\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nstore_name: sample11\nlegal_entity_name: legal11\nstore_address: address11', '2024-06-18 07:48:25', '2024-06-18 07:48:25'),
('2715561d-31f4-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '27153ce8-31f4-11ef-a30f-0a002700000d', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-2713761c\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 179.20\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-24 06:36:56', '2024-06-24 06:36:56'),
('2bb64213-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-2bb4d85b\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-24 07:27:11', '2024-06-24 07:27:11'),
('2bb7b24b-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 2bb4d85b-31fb-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:27:11', '2024-06-24 07:27:11'),
('2bb80317-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 2bb4d85b-31fb-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:27:11', '2024-06-24 07:27:11'),
('2ec2656b-31f3-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '2ec24d91-31f3-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-2ec0997c\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 48.58\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26547.32', '2024-06-24 06:30:00', '2024-06-24 06:30:00'),
('3c942c76-31f3-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '3c941093-31f3-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-3c92ce35\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 47.24\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26548.66', '2024-06-24 06:30:23', '2024-06-24 06:30:23'),
('3caf218d-1f21-11ef-a08a-48e7dad87c24', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Add', 'User record added\nemail_address: admin@bookymail.ph\npassword: admin123\nname: Admin\ntype: Admin\nstatus: Active', '2024-05-31 07:41:48', '2024-05-31 07:41:48'),
('41a37f61-2d28-11ef-a7c7-0a002700000d', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_fulfillment_type: Coupled -> Decoupled', '2024-06-18 04:07:19', '2024-06-18 04:07:19'),
('421419bb-31f7-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', '4212c6cf-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_date: \nsettlement_number: 202405-4212c6\nsettlement_period: \ntotal_amount: N/A\ncommission_rate: N/A\nvat_amount: N/A\ntotal_commission_fees: N/A', '2024-06-24 06:59:10', '2024-06-24 06:59:10'),
('446c137a-1f21-11ef-a08a-48e7dad87c24', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Update', 'User record updated\npassword: admin123 -> admin123booky', '2024-05-31 07:42:01', '2024-05-31 07:42:01'),
('44c1bfb4-2d51-11ef-a4d2-48e7dad87c24', NULL, 'report_history_coupled', '44c1a44d-2d51-11ef-a4d2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-44c085\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_net_sales: 18060.00\nleadgen_commission_rate_base_pretrial: 2490.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 278.88\nleadgen_commission_rate_base_billable: 15570.00\ncommission_rate_billable: 10.00%\ntotal_billable: 1743.84\ntotal_commission_fees: 1743.84', '2024-06-18 09:00:54', '2024-06-18 09:00:54'),
('494a3736-2ebc-11ef-abc9-48e7dad87c24', NULL, 'fee', '494a1d41-2ebc-11ef-abc9-48e7dad87c24', 'Add', 'Fee record added\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\npaymaya_credit_card: 0.00\npaymaya: 0.00\ngcash: 0.00\ngcash_miniapp: 0.00\nmaya_checkout: 0.00\nmaya: 0.00\nlead_gen_commission: 0.00\ncommission_type: VAT Inc', '2024-06-20 04:19:29', '2024-06-20 04:19:29'),
('538256ba-31fa-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', '53818781-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-53818781\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:21:08', '2024-06-24 07:21:08'),
('5384285f-31fa-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '53818781-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 53818781-31fa-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:21:08', '2024-06-24 07:21:08'),
('5384315e-31fa-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '53818781-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 53818781-31fa-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:21:08', '2024-06-24 07:21:08'),
('599dd82f-2d50-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_head', '599d1847-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-599d18', '2024-06-18 08:54:19', '2024-06-18 08:54:19'),
('59a03527-2d50-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_body', '599d1847-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: 599d1847-2d50-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:54:19', '2024-06-18 08:54:19'),
('61af7a9b-31ef-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '61af61a6-31ef-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-61ae33\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 06:02:47', '2024-06-24 06:02:47'),
('63f30570-31f7-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', '63f1b962-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_date: Jun 24, 2024\nsettlement_number: 202405-63f1b962\nsettlement_period: May 1 - May 31, 2024\ntotal_amount: 1600.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:00:07', '2024-06-24 07:00:07'),
('63f531cb-31f7-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '63f1b962-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 63f1b962-31f7-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00\namount: 1600.00', '2024-06-24 07:00:07', '2024-06-24 07:00:07'),
('6990aac1-31ee-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '69909518-31ee-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-698f4d\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_outstanding_amount_1: 1600.00\nleadgen_commission_rate_base: 1600.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 179.20\ncard_payment_pg_fee: 0.00\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 44.00\ntotal_outstanding_amount_2: 1600.00\ntotal_commission_fees_2: 179.20\ntotal_payment_gateway_fees_2: 44.00\nbank_fees: 10.00\ncwt_from_gross_sales: 8.78\ncwt_from_transaction_fees: 3.20\ncwt_from_pg_fees: 0.79\ntotal_amount_paid_out: 1362.01', '2024-06-24 05:55:51', '2024-06-24 05:55:51'),
('6b5975be-2d27-11ef-a7c7-0a002700000d', NULL, 'settlement_report_history_coupled', '6b5956c6-2d27-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-6b581a\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 802.98\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 802.98\nbank_fees: 10.00\ncwt_from_gross_sales: 107.21\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 14.34\ntotal_amount_paid_out: 13743.55', '2024-06-18 04:01:19', '2024-06-18 04:01:19'),
('6b8a3a3c-2ed7-11ef-bafd-48e7dad87c24', NULL, 'user', '6b8a15bf-2ed7-11ef-bafd-48e7dad87c24', 'Add', 'User record added\nemail_address: cookie@booky.ph\npassword: $2y$10$xXT7USa7PPtpQJm4g1xq8O..A2cKtV4/YbW.aJiKx0R2fobDZUa3m\nname: Cookie\ntype: User\nstatus: Inactive', '2024-06-20 07:33:42', '2024-06-20 07:33:42'),
('6e0aca8a-2d3e-11ef-a4d2-48e7dad87c24', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nfixed_discount: 0 -> 1\nfree_item: 0 -> 1', '2024-06-18 06:46:02', '2024-06-18 06:46:02'),
('74ad52f2-31f7-11ef-a30f-0a002700000d', NULL, 'transaction', '1bc0f5fe-224b-11ef-b01f-48e7dad87c24', 'Update', 'Transaction record updated\npayment: paymaya_credit_card -> gcash', '2024-06-24 07:00:35', '2024-06-24 07:00:35'),
('74b3c994-2d22-11ef-a7c7-0a002700000d', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_fulfillment_type: Decoupled -> Coupled', '2024-06-18 03:25:48', '2024-06-18 03:25:48'),
('74b5ff0a-31f7-11ef-a30f-0a002700000d', NULL, 'transaction', '8d1552bf-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Transaction record updated\npayment: gcash_miniapp -> gcash', '2024-06-24 07:00:35', '2024-06-24 07:00:35'),
('770a5f73-2d22-11ef-a7c7-0a002700000d', NULL, 'settlement_report_history_coupled', '770a0718-2d22-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-7708ad\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 2466.32\nleadgen_commission_rate_base: 2466.32\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2268.80\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 1121.04\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 1145.52\ntotal_outstanding_amount_2: 2466.32\ntotal_commission_fees_2: 2268.80\ntotal_payment_gateway_fees_2: 1145.52\nbank_fees: 10.00\ncwt_from_gross_sales: 12.33\ncwt_from_transaction_fees: 4.31\ncwt_from_pg_fees: 20.46\ntotal_amount_paid_out: -945.56', '2024-06-18 03:25:52', '2024-06-18 03:25:52'),
('7a4cca3d-31f7-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', '7a45e8c3-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-7a45e8c3\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:00:44', '2024-06-24 07:00:44'),
('7ab1ac90-31f7-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', '7a45e8c3-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 7a45e8c3-31f7-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 3\nnet_amount: 15570.00\namount: 46710.00', '2024-06-24 07:00:45', '2024-06-24 07:00:45'),
('7d48141a-2d22-11ef-a7c7-0a002700000d', NULL, 'settlement_report_history_coupled', '7d47f605-2d22-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-7d46e9\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 28916.00\nleadgen_commission_rate_base: 28916.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2541.06\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 1121.04\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 1145.52\ntotal_outstanding_amount_2: 28916.00\ntotal_commission_fees_2: 2541.06\ntotal_payment_gateway_fees_2: 1145.52\nbank_fees: 10.00\ncwt_from_gross_sales: 183.34\ncwt_from_transaction_fees: 45.38\ncwt_from_pg_fees: 20.46\ntotal_amount_paid_out: 25101.92', '2024-06-18 03:26:02', '2024-06-18 03:26:02'),
('81d181ba-31f2-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '81d155ed-31f2-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-81d08642\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 47.24\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26548.66', '2024-06-24 06:25:10', '2024-06-24 06:25:10'),
('828b4bc6-2eb6-11ef-abc9-48e7dad87c24', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_amount: 100.00 -> 120.00', '2024-06-20 03:38:08', '2024-06-20 03:38:08'),
('85051eec-2d50-11ef-a4d2-48e7dad87c24', NULL, 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Promo record added\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\npromo_code: GCA5H\npromo_amount: 200.00\npromo_fulfillment_type: Coupled\npromo_group: Gcash\nbogo: 0\nbundle: 0\nfixed_discount: 1\nfree_item: 0\npercent_discount: 0\nx_for_y: 0\npromo_details: gcash promo details\nremarks: N/A\nbill_status: PRE-TRIAL\nstart_date: 2024-03-01\nend_date: 2024-07-31', '2024-06-18 08:55:32', '2024-06-18 08:55:32'),
('8b553d09-2d26-11ef-a7c7-0a002700000d', NULL, 'settlement_report_history_coupled', '8b552490-2d26-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-8b540d\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 802.98\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 802.98\nbank_fees: 10.00\ncwt_from_gross_sales: 107.21\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 14.34\ntotal_amount_paid_out: 13743.55', '2024-06-18 03:55:04', '2024-06-18 03:55:04'),
('8fad4d33-31ee-11ef-a30f-0a002700000d', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nvoucher_type: Decoupled -> Coupled', '2024-06-24 05:56:55', '2024-06-24 05:56:55'),
('97e42414-2ebe-11ef-abc9-48e7dad87c24', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_type: 0 -> Free item, Fixed discount', '2024-06-20 04:35:59', '2024-06-20 04:35:59'),
('99f84246-31ee-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', '99f82de1-31ee-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-99f763\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 68.48\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 05:57:12', '2024-06-24 05:57:12'),
('a2f1259c-2d24-11ef-a7c7-0a002700000d', NULL, 'settlement_report_history_coupled', 'a2f101ad-2d24-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-a2f018\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 802.98\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 802.98\nbank_fees: 10.00\ncwt_from_gross_sales: 107.21\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 14.34\ntotal_amount_paid_out: 13743.55', '2024-06-18 03:41:24', '2024-06-18 03:41:24'),
('a3d1d89c-2ebe-11ef-abc9-48e7dad87c24', NULL, 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Promo record updated\npromo_type: 0 -> BOGO', '2024-06-20 04:36:19', '2024-06-20 04:36:19'),
('a667cc4e-2d50-11ef-a4d2-48e7dad87c24', NULL, 'transaction', 'a6673ec0-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Transaction record added\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\npromo_id: 8504f541-2d50-11ef-a4d2-48e7dad87c24\ncustomer_id: \"638572947601\"\ntransaction_date: 2024-06-18 10:55:41\ngross_amount: 1800.00\ndiscount: 200.00\namount_discounted: 1600.00\npayment: gcash\nbill_status: PRE-TRIAL', '2024-06-18 08:56:28', '2024-06-18 08:56:28'),
('abc213d1-31f7-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', 'abc1668b-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-abc1668b\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:02:08', '2024-06-24 07:02:08'),
('af210407-2ebe-11ef-abc9-48e7dad87c24', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nremarks:  -> not billable \"forever\"', '2024-06-20 04:36:38', '2024-06-20 04:36:38'),
('b0ad6776-2eb8-11ef-abc9-48e7dad87c24', NULL, 'report_history_coupled', 'b0acea51-2eb8-11ef-abc9-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-b0ab5e\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 68.48\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-20 03:53:44', '2024-06-20 03:53:44'),
('b115b12c-31f2-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', 'b1159c73-31f2-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-b11440c7\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 48.58\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26547.32', '2024-06-24 06:26:29', '2024-06-24 06:26:29'),
('b123f325-31fa-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', 'b1230378-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-b1230378\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:23:45', '2024-06-24 07:23:45'),
('b125cb0e-31fa-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', 'b1230378-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: b1230378-31fa-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:23:45', '2024-06-24 07:23:45'),
('b125cdfb-31fa-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', 'b1230378-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: b1230378-31fa-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:23:45', '2024-06-24 07:23:45'),
('b42ef62c-2d4e-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_head', 'b42ddf53-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-b42ddf', '2024-06-18 08:42:32', '2024-06-18 08:42:32'),
('b430d7f0-2d4e-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_body', 'b42ddf53-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: b42ddf53-2d4e-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:42:32', '2024-06-18 08:42:32'),
('b5d55419-2d50-11ef-a4d2-48e7dad87c24', NULL, 'transaction', 'a6673ec0-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Transaction record updated\ntransaction_date: 2024-06-18 10:55:41 -> 2024-05-18 10:55:41', '2024-06-18 08:56:54', '2024-06-18 08:56:54'),
('b7843bb5-31f1-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', 'b7842860-31f1-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-b78352\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 06:19:30', '2024-06-24 06:19:30'),
('bb92c21d-2d50-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_head', 'bb91e9e6-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-bb91e9', '2024-06-18 08:57:03', '2024-06-18 08:57:03'),
('bc030dcd-2eb6-11ef-abc9-48e7dad87c24', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-06-20 03:39:44', '2024-06-20 03:39:44'),
('bc031474-2eb6-11ef-abc9-48e7dad87c24', NULL, 'promo_history', 'bc03116e-2eb6-11ef-abc9-48e7dad87c24', 'Add', 'Promo history record added\npromo_code: B00KYDEMO\nold_bill_status: BILLABLE\nnew_bill_status: PRE-TRIAL\nchanged_at: 2024-06-20\nchanged_by: N/A', '2024-06-20 03:39:44', '2024-06-20 03:39:44'),
('bcd83021-2927-11ef-8b55-0a002700000d', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Update', 'User record updated\nname: Admin -> Booky Admin', '2024-06-13 01:53:32', '2024-06-13 01:53:32'),
('bd900b46-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', 'bd8ef28d-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-bd8ef28d\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-24 07:31:15', '2024-06-24 07:31:15'),
('bd91f740-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', 'bd8ef28d-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: bd8ef28d-31fb-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:31:15', '2024-06-24 07:31:15'),
('bd91fb26-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', 'bd8ef28d-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: bd8ef28d-31fb-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:31:15', '2024-06-24 07:31:15'),
('bd9a1e69-2d1e-11ef-a7c7-0a002700000d', NULL, 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_fulfillment_type: Coupled -> Decoupled', '2024-06-18 02:59:12', '2024-06-18 02:59:12'),
('cf1512db-2d50-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_head', 'cf141684-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-cf1416', '2024-06-18 08:57:36', '2024-06-18 08:57:36'),
('cf17118f-2d50-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_body', 'cf141684-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: cf141684-2d50-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 4\nvoucher_value: 100.00\namount: 400.00', '2024-06-18 08:57:36', '2024-06-18 08:57:36'),
('cfb99b97-31ee-11ef-a30f-0a002700000d', NULL, 'transaction', '8d1552bf-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Transaction record updated\npayment: gcash -> gcash_miniapp', '2024-06-24 05:58:42', '2024-06-24 05:58:42'),
('d450e7af-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_head', 'd4502354-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-d4502354\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-24 07:31:54', '2024-06-24 07:31:54'),
('d45289a1-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', 'd4502354-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: d4502354-31fb-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:31:54', '2024-06-24 07:31:54'),
('d4528daf-31fb-11ef-a30f-0a002700000d', NULL, 'report_history_gcash_body', 'd4502354-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: d4502354-31fb-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:31:54', '2024-06-24 07:31:54'),
('d9221845-31ee-11ef-a30f-0a002700000d', NULL, 'report_history_coupled', 'd9220200-31ee-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-d920d1\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 05:58:58', '2024-06-24 05:58:58'),
('e4bc7553-2d4e-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_head', 'e4bbda63-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-e4bbda', '2024-06-18 08:43:54', '2024-06-18 08:43:54'),
('e4c02508-2d4e-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_body', 'e4bbda63-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: e4bbda63-2d4e-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:43:54', '2024-06-18 08:43:54'),
('e5a31a2a-2eb6-11ef-abc9-48e7dad87c24', NULL, 'transaction', '1bc0f5fe-224b-11ef-b01f-48e7dad87c24', 'Update', 'Transaction record updated\npromo_id: 4e3030a7-1cc3-11ef-8abb-48e7dad87c24 -> B00KYDEMO', '2024-06-20 03:40:54', '2024-06-20 03:40:54'),
('eb6d338b-2d4e-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_head', 'eb6c4798-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-eb6c47', '2024-06-18 08:44:05', '2024-06-18 08:44:05'),
('eb6e79d2-2d4e-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_body', 'eb6c4798-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: eb6c4798-2d4e-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:44:05', '2024-06-18 08:44:05'),
('f15b0edb-2d50-11ef-a4d2-48e7dad87c24', NULL, 'report_history_gcash_head', 'f15a327b-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-f15a32', '2024-06-18 08:58:34', '2024-06-18 08:58:34'),
('f70bc8b5-2eb6-11ef-abc9-48e7dad87c24', NULL, 'transaction', '8d1552bf-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Transaction record updated\npromo_id: 4e3030a7-1cc3-11ef-8abb-48e7dad87c24 -> B00KYDEMO', '2024-06-20 03:41:23', '2024-06-20 03:41:23'),
('f70bdc1c-2eb6-11ef-abc9-48e7dad87c24', NULL, 'transaction', 'e881c2e7-224a-11ef-b01f-48e7dad87c24', 'Update', 'Transaction record updated\npromo_id: 4e3030a7-1cc3-11ef-8abb-48e7dad87c24 -> B00KYDEMO', '2024-06-20 03:41:23', '2024-06-20 03:41:23');

--
-- Triggers `activity_history`
--
DELIMITER $$
CREATE TRIGGER `generate_activity_id` BEFORE INSERT ON `activity_history` FOR EACH ROW BEGIN
    SET NEW.activity_id = UUID(); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `fee`
--

CREATE TABLE `fee` (
  `fee_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `paymaya_credit_card` decimal(4,2) NOT NULL DEFAULT 0.00,
  `paymaya` decimal(4,2) NOT NULL DEFAULT 0.00,
  `gcash` decimal(4,2) NOT NULL DEFAULT 0.00,
  `gcash_miniapp` decimal(4,2) NOT NULL DEFAULT 0.00,
  `maya_checkout` decimal(4,2) NOT NULL DEFAULT 0.00,
  `maya` decimal(4,2) NOT NULL DEFAULT 0.00,
  `lead_gen_commission` decimal(4,2) NOT NULL DEFAULT 0.00,
  `commission_type` enum('VAT Inc','VAT Exc') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fee`
--

INSERT INTO `fee` (`fee_id`, `merchant_id`, `paymaya_credit_card`, `paymaya`, `gcash`, `gcash_miniapp`, `maya_checkout`, `maya`, `lead_gen_commission`, `commission_type`, `created_at`, `updated_at`) VALUES
('02f361d3-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', '2.75', '2.50', '3.00', '3.00', '2.75', '2.50', '5.00', 'VAT Inc', '2024-05-28 07:22:16', '2024-06-04 04:34:38');

--
-- Triggers `fee`
--
DELIMITER $$
CREATE TRIGGER `before_insert_fee` BEFORE INSERT ON `fee` FOR EACH ROW BEGIN
  SET NEW.maya_checkout = NEW.paymaya_credit_card;
  SET NEW.paymaya = NEW.maya;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_fee` BEFORE UPDATE ON `fee` FOR EACH ROW BEGIN
  SET NEW.maya_checkout = NEW.paymaya_credit_card;
  SET NEW.paymaya = NEW.maya;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `fee_insert_log` AFTER INSERT ON `fee` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Fee record added\n',
  'merchant_id: ', IFNULL(NEW.merchant_id, 'N/A'), 
  '\n','paymaya_credit_card: ', IFNULL(NEW.paymaya_credit_card, 'N/A'), 
  '\n','paymaya: ', IFNULL(NEW.paymaya, 'N/A'), 
  '\n','gcash: ', IFNULL(NEW.gcash, 'N/A'),
  '\n','gcash_miniapp: ', IFNULL(NEW.gcash_miniapp, 'N/A'),
  '\n','maya_checkout: ', IFNULL(NEW.maya_checkout, 'N/A'),
  '\n','maya: ', IFNULL(NEW.maya, 'N/A'),
  '\n','lead_gen_commission: ', IFNULL(NEW.lead_gen_commission, 'N/A'),
  '\n','commission_type: ', IFNULL(NEW.commission_type, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('fee', NEW.fee_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `fee_update_log` AFTER UPDATE ON `fee` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Fee record updated\n';

  IF OLD.merchant_id != NEW.merchant_id THEN
    SET description = CONCAT(description, 'merchant_id: ', OLD.merchant_id, ' -> ', NEW.merchant_id, '\n');
  END IF;

  IF OLD.paymaya_credit_card != NEW.paymaya_credit_card THEN
    SET description = CONCAT(description, 'paymaya_credit_card: ', OLD.paymaya_credit_card, ' -> ', NEW.paymaya_credit_card, '\n');
  END IF;

  IF OLD.paymaya != NEW.paymaya THEN
    SET description = CONCAT(description, 'paymaya: ', OLD.paymaya, ' -> ', NEW.paymaya, '\n');
  END IF;

  IF OLD.gcash != NEW.gcash THEN
    SET description = CONCAT(description, 'gcash: ', OLD.gcash, ' -> ', NEW.gcash, '\n');
  END IF;
  
  IF OLD.gcash_miniapp != NEW.gcash_miniapp THEN
    SET description = CONCAT(description, 'gcash_miniapp: ', OLD.gcash_miniapp, ' -> ', NEW.gcash_miniapp, '\n');
  END IF;
  
  IF OLD.maya_checkout != NEW.maya_checkout THEN
    SET description = CONCAT(description, 'maya_checkout: ', OLD.maya_checkout, ' -> ', NEW.maya_checkout, '\n');
  END IF;
  
  IF OLD.maya != NEW.maya THEN
    SET description = CONCAT(description, 'maya: ', OLD.maya, ' -> ', NEW.maya, '\n');
  END IF;
  
  IF OLD.lead_gen_commission != NEW.lead_gen_commission THEN
    SET description = CONCAT(description, 'lead_gen_commission: ', OLD.lead_gen_commission, ' -> ', NEW.lead_gen_commission, '\n');
  END IF;
  
  IF OLD.commission_type != NEW.commission_type THEN
    SET description = CONCAT(description, 'commission_type: ', OLD.commission_type, ' -> ', NEW.commission_type, '\n');
  END IF;

  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('fee', NEW.fee_id, 'Update', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `generate_fee_id` BEFORE INSERT ON `fee` FOR EACH ROW BEGIN
    SET NEW.fee_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_fee_value` AFTER UPDATE ON `fee` FOR EACH ROW BEGIN
  IF OLD.paymaya_credit_card != NEW.paymaya_credit_card THEN
    INSERT INTO fee_history (fee_history_id, fee_id,column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'paymaya_credit_card', OLD.paymaya_credit_card, NEW.paymaya_credit_card);
  END IF;

  IF OLD.gcash != NEW.gcash THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'gcash', OLD.gcash, NEW.gcash);
  END IF;

  IF OLD.gcash_miniapp != NEW.gcash_miniapp THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'gcash_miniapp', OLD.gcash_miniapp, NEW.gcash_miniapp);
  END IF;

  IF OLD.paymaya != NEW.paymaya THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'paymaya', OLD.paymaya, NEW.paymaya);
  END IF;

  IF OLD.maya_checkout != NEW.maya_checkout THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'maya_checkout', OLD.maya_checkout, NEW.maya_checkout);
  END IF;

  IF OLD.maya != NEW.maya THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'maya', OLD.maya, NEW.maya);
  END IF;

  IF OLD.lead_gen_commission != NEW.lead_gen_commission THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'lead_gen_commission', OLD.lead_gen_commission, NEW.lead_gen_commission);
  END IF;
  
  IF OLD.commission_type != NEW.commission_type THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'commission_type', OLD.commission_type, NEW.commission_type);
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `fee_history`
--

CREATE TABLE `fee_history` (
  `fee_history_id` varchar(36) NOT NULL,
  `fee_id` varchar(36) NOT NULL,
  `column_name` varchar(50) NOT NULL,
  `old_value` varchar(50) NOT NULL,
  `new_value` varchar(50) NOT NULL,
  `changed_at` date NOT NULL DEFAULT current_timestamp(),
  `changed_by` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fee_history`
--

INSERT INTO `fee_history` (`fee_history_id`, `fee_id`, `column_name`, `old_value`, `new_value`, `changed_at`, `changed_by`) VALUES
('04a53aab-223f-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'gcash', '2.75', '3.00', '2024-06-04', NULL),
('04a54436-223f-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'gcash_miniapp', '2.75', '3.00', '2024-06-04', NULL),
('66638ca3-2241-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'paymaya', '2.00', '2.50', '2024-06-04', NULL),
('6c0f2a25-2310-11ef-a463-0a002700000d', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'paymaya', '2.00', '2.50', '2024-06-05', NULL),
('6c0f3167-2310-11ef-a463-0a002700000d', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'maya', '2.00', '2.50', '2024-06-05', NULL),
('9469bad9-2241-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'lead_gen_commission', '10.00', '5.00', '2024-06-04', NULL),
('9469bebf-2241-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'commission_type', 'VAT Exc', 'VAT Inc', '2024-06-04', NULL),
('b538bee7-224a-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'paymaya_credit_card', '2.00', '5.00', '2024-06-01', NULL),
('f49f03e3-230f-11ef-a463-0a002700000d', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'paymaya_credit_card', '5.00', '2.75', '2024-06-05', NULL),
('f49f1115-230f-11ef-a463-0a002700000d', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'paymaya', '2.50', '2.00', '2024-06-05', NULL),
('f49f1af1-230f-11ef-a463-0a002700000d', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'maya_checkout', '2.00', '2.75', '2024-06-05', NULL);

--
-- Triggers `fee_history`
--
DELIMITER $$
CREATE TRIGGER `fee_history_insert_log` AFTER INSERT ON `fee_history` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Fee history record added\n',
  'fee_id: ', IFNULL(NEW.fee_id, 'N/A'), 
  '\n','column_name: ', IFNULL(NEW.column_name, 'N/A'), 
  '\n','old_value: ', IFNULL(NEW.old_value, 'N/A'), 
  '\n','new_value: ', IFNULL(NEW.new_value, 'N/A'),
  '\n','changed_at: ', IFNULL(NEW.changed_at, 'N/A'),
  '\n','changed_by: ', IFNULL(NEW.changed_by, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('fee_history', NEW.fee_history_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `fee_history_update_log` AFTER UPDATE ON `fee_history` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Fee history record updated\n';

  IF OLD.fee_id != NEW.fee_id THEN
    SET description = CONCAT(description, 'fee_id: ', OLD.fee_id, ' -> ', NEW.fee_id, '\n');
  END IF;

  IF OLD.column_name != NEW.column_name THEN
    SET description = CONCAT(description, 'column_name: ', OLD.column_name, ' -> ', NEW.column_name, '\n');
  END IF;

  IF OLD.old_value != NEW.old_value THEN
    SET description = CONCAT(description, 'old_value: ', OLD.old_value, ' -> ', NEW.old_value, '\n');
  END IF;

  IF OLD.new_value != NEW.new_value THEN
    SET description = CONCAT(description, 'new_value: ', OLD.new_value, ' -> ', NEW.new_value, '\n');
  END IF;
  
  IF OLD.changed_at != NEW.changed_at THEN
    SET description = CONCAT(description, 'changed_at: ', OLD.changed_at, ' -> ', NEW.changed_at, '\n');
  END IF;
  
  IF OLD.changed_by != NEW.changed_by THEN
    SET description = CONCAT(description, 'changed_by: ', OLD.changed_by, ' -> ', NEW.changed_by, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('fee_history', NEW.fee_history_id, 'Update', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `generate_fee_history_id` BEFORE INSERT ON `fee_history` FOR EACH ROW BEGIN
    SET NEW.fee_history_id = UUID(); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `merchant`
--

CREATE TABLE `merchant` (
  `merchant_id` varchar(36) NOT NULL,
  `merchant_name` varchar(255) NOT NULL,
  `merchant_partnership_type` enum('Primary','Secondary') DEFAULT NULL,
  `legal_entity_name` varchar(255) DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `email_address` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant`
--

INSERT INTO `merchant` (`merchant_id`, `merchant_name`, `merchant_partnership_type`, `legal_entity_name`, `business_address`, `email_address`, `created_at`, `updated_at`) VALUES
('3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B00KY Demo Merchant', 'Primary', 'Merchant Legal Name', 'Somewhere St.', 'merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph', '2024-05-28 07:16:32', '2024-06-04 02:49:53');

--
-- Triggers `merchant`
--
DELIMITER $$
CREATE TRIGGER `generate_merchant_id` BEFORE INSERT ON `merchant` FOR EACH ROW BEGIN
    IF NEW.merchant_id IS NULL OR NEW.merchant_id = '' THEN
        SET NEW.merchant_id = UUID();
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `merchant_insert_log` AFTER INSERT ON `merchant` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Merchant record added\n',
  'merchant_name: ', IFNULL(NEW.merchant_name, 'N/A'), 
  '\n','merchant_partnership_type: ', IFNULL(NEW.merchant_partnership_type, 'N/A'), 
  '\n','legal_entity_name: ', IFNULL(NEW.legal_entity_name, 'N/A'),
  '\n','business_address: ', IFNULL(NEW.business_address, 'N/A'),
  '\n','email_address: ', IFNULL(NEW.email_address, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('merchant', NEW.merchant_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `merchant_update_log` AFTER UPDATE ON `merchant` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Merchant record updated\n';

  IF OLD.merchant_name != NEW.merchant_name THEN
    SET description = CONCAT(description, 'merchant_name: ', OLD.merchant_name, ' -> ', NEW.merchant_name, '\n');
  END IF;

  IF OLD.merchant_partnership_type != NEW.merchant_partnership_type THEN
    SET description = CONCAT(description, 'merchant_partnership_type: ', OLD.merchant_partnership_type, ' -> ', NEW.merchant_partnership_type, '\n');
  END IF;

  IF OLD.legal_entity_name != NEW.legal_entity_name THEN
    SET description = CONCAT(description, 'legal_entity_name: ', OLD.legal_entity_name, ' -> ', NEW.legal_entity_name, '\n');
  END IF;
  
  IF OLD.business_address != NEW.business_address THEN
    SET description = CONCAT(description, 'business_address: ', OLD.business_address, ' -> ', NEW.business_address, '\n');
  END IF;
  
  IF OLD.email_address != NEW.email_address THEN
    SET description = CONCAT(description, 'email_address: ', OLD.email_address, ' -> ', NEW.email_address, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('merchant', NEW.merchant_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `promo`
--

CREATE TABLE `promo` (
  `promo_id` varchar(36) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `promo_amount` int(11) NOT NULL DEFAULT 0,
  `voucher_type` enum('Coupled','Decoupled') NOT NULL,
  `promo_category` enum('Grab & Go','Casual Dining') DEFAULT NULL,
  `promo_group` enum('Booky','Gcash','Unionbank','Gcash/Booky','UB/Booky') NOT NULL,
  `promo_type` varchar(255) NOT NULL,
  `promo_details` text NOT NULL,
  `remarks` text DEFAULT NULL,
  `bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promo`
--

INSERT INTO `promo` (`promo_id`, `promo_code`, `merchant_id`, `promo_amount`, `voucher_type`, `promo_category`, `promo_group`, `promo_type`, `promo_details`, `remarks`, `bill_status`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
('4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'B00KYDEMO', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 120, 'Coupled', 'Grab & Go', 'Gcash', 'Free item, Fixed discount', 'Booky sample promo', 'not billable \"forever\"', 'PRE-TRIAL', '2024-04-01', '2024-07-31', '2024-06-04 02:34:19', '2024-06-20 04:35:59'),
('8504f541-2d50-11ef-a4d2-48e7dad87c24', 'GCA5H', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 200, 'Decoupled', 'Casual Dining', 'Gcash', 'BOGO', 'gcash promo details', NULL, 'PRE-TRIAL', '2024-03-01', '2024-07-31', '2024-06-18 08:55:32', '2024-06-20 04:36:19');

--
-- Triggers `promo`
--
DELIMITER $$
CREATE TRIGGER `generate_promo_id` BEFORE INSERT ON `promo` FOR EACH ROW BEGIN
    SET NEW.promo_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `promo_insert_log` AFTER INSERT ON `promo` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Promo record added\n',
  '\n','promo_code: ', IFNULL(NEW.promo_code, 'N/A'), 
  '\n','merchant_id: ', IFNULL(NEW.merchant_id, 'N/A'),
  '\n','promo_amount: ', IFNULL(NEW.promo_amount, 'N/A'), 
  '\n','voucher_type: ', IFNULL(NEW.voucher_type, 'N/A'),
  '\n','promo_category: ', IFNULL(NEW.promo_category, 'N/A'), 
  '\n','promo_group: ', IFNULL(NEW.promo_group, 'N/A'),
  '\n','promo_type: ', IFNULL(NEW.promo_type, 'N/A'),
  '\n','promo_details: ', IFNULL(NEW.promo_details, 'N/A'),
  '\n','remarks: ', IFNULL(NEW.remarks, 'N/A'),
  '\n','bill_status: ', IFNULL(NEW.bill_status, 'N/A'),
  '\n','start_date: ', IFNULL(NEW.start_date, 'N/A'),
  '\n','end_date: ', IFNULL(NEW.end_date, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('promo', NEW.promo_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `promo_update_log` AFTER UPDATE ON `promo` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Promo record updated\n';

  IF OLD.promo_code != NEW.promo_code THEN
    SET description = CONCAT(description, 'promo_code: ', OLD.promo_code, ' -> ', NEW.promo_code, '\n');
  END IF;
  
  IF OLD.merchant_id != NEW.merchant_id THEN
    SET description = CONCAT(description, 'merchant_id: ', OLD.merchant_id, ' -> ', NEW.merchant_id, '\n');
  END IF;

  IF OLD.promo_amount != NEW.promo_amount THEN
    SET description = CONCAT(description, 'promo_amount: ', OLD.promo_amount, ' -> ', NEW.promo_amount, '\n');
  END IF;

  IF OLD.voucher_type != NEW.voucher_type THEN
    SET description = CONCAT(description, 'voucher_type: ', OLD.voucher_type, ' -> ', NEW.voucher_type, '\n');
  END IF;
  
  IF OLD.promo_category != NEW.promo_category THEN
    SET description = CONCAT(description, 'promo_category: ', OLD.promo_category, ' -> ', NEW.promo_category, '\n');
  END IF;
  
  IF OLD.promo_group != NEW.promo_group THEN
    SET description = CONCAT(description, 'promo_group: ', OLD.promo_group, ' -> ', NEW.promo_group, '\n');
  END IF;
  
  IF OLD.promo_type != NEW.promo_type THEN
    SET description = CONCAT(description, 'promo_type: ', OLD.promo_type, ' -> ', NEW.promo_type, '\n');
  END IF;
  
  IF OLD.promo_details != NEW.promo_details THEN
    SET description = CONCAT(description, 'promo_details: ', OLD.promo_details, ' -> ', NEW.promo_details, '\n');
  END IF;
  
  IF OLD.remarks != NEW.remarks THEN
    SET description = CONCAT(description, 'remarks: ', OLD.remarks, ' -> ', NEW.remarks, '\n');
  END IF;
  
  IF OLD.bill_status != NEW.bill_status THEN
    SET description = CONCAT(description, 'bill_status: ', OLD.bill_status, ' -> ', NEW.bill_status, '\n');
  END IF;
  
  IF OLD.start_date != NEW.start_date THEN
    SET description = CONCAT(description, 'start_date: ', OLD.start_date, ' -> ', NEW.start_date, '\n');
  END IF;
  
  IF OLD.end_date != NEW.end_date THEN
    SET description = CONCAT(description, 'end_date: ', OLD.end_date, ' -> ', NEW.end_date, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('promo', NEW.promo_id, 'Update', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_bill_status` AFTER UPDATE ON `promo` FOR EACH ROW BEGIN
  IF OLD.bill_status != NEW.bill_status THEN
    INSERT INTO promo_history (promo_history_id, promo_code, old_bill_status, new_bill_status)
    VALUES (UUID(), NEW.promo_code, OLD.bill_status, NEW.bill_status);
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `promo_history`
--

CREATE TABLE `promo_history` (
  `promo_history_id` varchar(36) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `old_bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `new_bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `changed_at` date NOT NULL DEFAULT current_timestamp(),
  `changed_by` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promo_history`
--

INSERT INTO `promo_history` (`promo_history_id`, `promo_code`, `old_bill_status`, `new_bill_status`, `changed_at`, `changed_by`) VALUES
('bc03116e-2eb6-11ef-abc9-48e7dad87c24', 'B00KYDEMO', 'BILLABLE', 'PRE-TRIAL', '2024-06-20', NULL);

--
-- Triggers `promo_history`
--
DELIMITER $$
CREATE TRIGGER `generate_promo_history_id` BEFORE INSERT ON `promo_history` FOR EACH ROW BEGIN
    SET NEW.promo_history_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `promo_history_insert_log` AFTER INSERT ON `promo_history` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Promo history record added\n',
  'promo_code: ', IFNULL(NEW.promo_code, 'N/A'), 
  '\n','old_bill_status: ', IFNULL(NEW.old_bill_status, 'N/A'), 
  '\n','new_bill_status: ', IFNULL(NEW.new_bill_status, 'N/A'), 
  '\n','changed_at: ', IFNULL(NEW.changed_at, 'N/A'),
  '\n','changed_by: ', IFNULL(NEW.changed_by, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('promo_history', NEW.promo_history_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `promo_history_update_log` AFTER UPDATE ON `promo_history` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Promo history record updated\n';

  IF OLD.promo_code != NEW.promo_code THEN
    SET description = CONCAT(description, 'promo_code: ', OLD.promo_code, ' -> ', NEW.promo_code, '\n');
  END IF;

  IF OLD.old_bill_status != NEW.old_bill_status THEN
    SET description = CONCAT(description, 'old_bill_status: ', OLD.old_bill_status, ' -> ', NEW.old_bill_status, '\n');
  END IF;

  IF OLD.new_bill_status != NEW.new_bill_status THEN
    SET description = CONCAT(description, 'new_bill_status: ', OLD.new_bill_status, ' -> ', NEW.new_bill_status, '\n');
  END IF;

  IF OLD.changed_at != NEW.changed_at THEN
    SET description = CONCAT(description, 'changed_at: ', OLD.changed_at, ' -> ', NEW.changed_at, '\n');
  END IF;
  
  IF OLD.changed_by != NEW.changed_by THEN
    SET description = CONCAT(description, 'changed_by: ', OLD.changed_by, ' -> ', NEW.changed_by, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('promo_history', NEW.promo_history_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `report_history_coupled`
--

CREATE TABLE `report_history_coupled` (
  `coupled_report_id` varchar(36) NOT NULL,
  `generated_by` varchar(36) DEFAULT NULL,
  `merchant_id` varchar(36) DEFAULT NULL,
  `merchant_business_name` varchar(255) DEFAULT NULL,
  `merchant_brand_name` varchar(255) DEFAULT NULL,
  `store_id` varchar(36) DEFAULT NULL,
  `store_business_name` varchar(255) DEFAULT NULL,
  `store_brand_name` varchar(255) DEFAULT NULL,
  `business_address` text NOT NULL,
  `settlement_period_start` date NOT NULL,
  `settlement_period_end` date NOT NULL,
  `settlement_date` varchar(30) NOT NULL,
  `settlement_number` varchar(20) NOT NULL,
  `settlement_period` varchar(30) NOT NULL,
  `total_successful_orders` int(11) NOT NULL,
  `total_gross_sales` decimal(10,2) NOT NULL,
  `total_discount` decimal(10,2) NOT NULL,
  `total_outstanding_amount_1` decimal(10,2) NOT NULL,
  `leadgen_commission_rate_base` decimal(10,2) NOT NULL,
  `commission_rate` varchar(10) NOT NULL,
  `total_commission_fees_1` decimal(10,2) NOT NULL,
  `card_payment_pg_fee` decimal(10,2) NOT NULL,
  `paymaya_pg_fee` decimal(10,2) NOT NULL,
  `gcash_miniapp_pg_fee` decimal(10,2) NOT NULL,
  `gcash_pg_fee` decimal(10,2) NOT NULL,
  `total_payment_gateway_fees_1` decimal(10,2) NOT NULL,
  `total_outstanding_amount_2` decimal(10,2) NOT NULL,
  `total_commission_fees_2` decimal(10,2) NOT NULL,
  `total_payment_gateway_fees_2` decimal(10,2) NOT NULL,
  `bank_fees` decimal(5,2) NOT NULL,
  `cwt_from_gross_sales` decimal(10,2) NOT NULL,
  `cwt_from_transaction_fees` decimal(10,2) NOT NULL,
  `cwt_from_pg_fees` decimal(10,2) NOT NULL,
  `total_amount_paid_out` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `report_history_coupled`
--

INSERT INTO `report_history_coupled` (`coupled_report_id`, `generated_by`, `merchant_id`, `merchant_business_name`, `merchant_brand_name`, `store_id`, `store_business_name`, `store_brand_name`, `business_address`, `settlement_period_start`, `settlement_period_end`, `settlement_date`, `settlement_number`, `settlement_period`, `total_successful_orders`, `total_gross_sales`, `total_discount`, `total_outstanding_amount_1`, `leadgen_commission_rate_base`, `commission_rate`, `total_commission_fees_1`, `card_payment_pg_fee`, `paymaya_pg_fee`, `gcash_miniapp_pg_fee`, `gcash_pg_fee`, `total_payment_gateway_fees_1`, `total_outstanding_amount_2`, `total_commission_fees_2`, `total_payment_gateway_fees_2`, `bank_fees`, `cwt_from_gross_sales`, `cwt_from_transaction_fees`, `cwt_from_pg_fees`, `total_amount_paid_out`, `created_at`, `updated_at`) VALUES
('2ec24d91-31f3-11ef-a30f-0a002700000d', NULL, '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Merchant Legal Name', 'B00KY Demo Merchant', NULL, NULL, NULL, 'Somewhere St.', '2024-05-01', '2024-06-30', 'Jun 24, 2024', '202406-2ec0997c', 'May 1 - Jun 30, 2024', 4, '39614.00', '9098.00', '30516.00', '30516.00', '10.00%', '2645.52', '1121.04', '0.00', '24.48', '44.00', '1189.52', '30516.00', '2645.52', '1189.52', '10.00', '192.12', '48.58', '21.24', '26547.32', '2024-06-24 06:30:00', '2024-06-24 06:30:00'),
('3c941093-31f3-11ef-a30f-0a002700000d', NULL, NULL, NULL, NULL, '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'Demo Legal Name', 'B00KY Demo Store', 'Anywhere St.', '2024-05-01', '2024-06-30', 'Jun 24, 2024', '202406-3c92ce35', 'May 1 - Jun 30, 2024', 4, '39614.00', '9098.00', '30516.00', '30516.00', '10.00%', '2645.52', '1121.04', '0.00', '24.48', '44.00', '1189.52', '30516.00', '2645.52', '1189.52', '10.00', '192.12', '47.24', '21.24', '26548.66', '2024-06-24 06:30:23', '2024-06-24 06:30:23');

--
-- Triggers `report_history_coupled`
--
DELIMITER $$
CREATE TRIGGER `report_history_coupled_insert_log` AFTER INSERT ON `report_history_coupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Coupled report history record added\n',
  'generated_by: ', IFNULL(NEW.generated_by, 'N/A'), 
  '\n','merchant_id: ', IFNULL(NEW.merchant_id, 'N/A'), 
  '\n','merchant_business_name: ', IFNULL(NEW.merchant_business_name, 'N/A'), 
  '\n','merchant_brand_name: ', IFNULL(NEW.merchant_brand_name, 'N/A'),
  '\n','store_id: ', IFNULL(NEW.store_id, 'N/A'),
  '\n','store_business_name: ', IFNULL(NEW.store_business_name, 'N/A'), 
  '\n','store_brand_name: ', IFNULL(NEW.store_brand_name, 'N/A'),
  '\n','business_address: ', IFNULL(NEW.business_address, 'N/A'),
  '\n','settlement_period_start: ', IFNULL(NEW.settlement_period_start, 'N/A'),
  '\n','settlement_period_end: ', IFNULL(NEW.settlement_period_end, 'N/A'),
  '\n','settlement_number: ', IFNULL(NEW.settlement_number, 'N/A'),
                          
  '\n','total_successful_orders: ', IFNULL(NEW.total_successful_orders, 'N/A'),
  '\n','total_gross_sales: ', IFNULL(NEW.total_gross_sales, 'N/A'),
  '\n','total_discount: ', IFNULL(NEW.total_discount, 'N/A'),
  '\n','total_outstanding_amount_1: ', IFNULL(NEW.total_outstanding_amount_1, 'N/A'),
  '\n','leadgen_commission_rate_base: ', IFNULL(NEW.leadgen_commission_rate_base, 'N/A'),
  '\n','commission_rate: ', IFNULL(NEW.commission_rate, 'N/A'),
  '\n','total_commission_fees_1: ', IFNULL(NEW.total_commission_fees_1, 'N/A'),
  '\n','card_payment_pg_fee: ', IFNULL(NEW.card_payment_pg_fee, 'N/A'),
  '\n','paymaya_pg_fee: ', IFNULL(NEW.paymaya_pg_fee, 'N/A'),
  '\n','gcash_miniapp_pg_fee: ', IFNULL(NEW.gcash_miniapp_pg_fee, 'N/A'),
  '\n','gcash_pg_fee: ', IFNULL(NEW.gcash_pg_fee, 'N/A'),
  '\n','total_payment_gateway_fees_1: ', IFNULL(NEW.total_payment_gateway_fees_1, 'N/A'),
  '\n','total_outstanding_amount_2: ', IFNULL(NEW.total_outstanding_amount_2, 'N/A'),
  '\n','total_commission_fees_2: ', IFNULL(NEW.total_commission_fees_2, 'N/A'),
  '\n','total_payment_gateway_fees_2: ', IFNULL(NEW.total_payment_gateway_fees_2, 'N/A'),
  '\n','bank_fees: ', IFNULL(NEW.bank_fees, 'N/A'),
  '\n','cwt_from_gross_sales: ', IFNULL(NEW.cwt_from_gross_sales, 'N/A'),
  '\n','cwt_from_transaction_fees: ', IFNULL(NEW.cwt_from_transaction_fees, 'N/A'),
  '\n','cwt_from_pg_fees: ', IFNULL(NEW.cwt_from_pg_fees, 'N/A'),
  '\n','total_amount_paid_out: ', IFNULL(NEW.total_amount_paid_out, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_coupled', NEW.coupled_report_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `report_history_coupled_update_log` AFTER UPDATE ON `report_history_coupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Coupled report history record updated\n';

  IF OLD.generated_by != NEW.generated_by THEN
    SET description = CONCAT(description, 'generated_by: ', OLD.generated_by, ' -> ', NEW.generated_by, '\n');
  END IF;

  IF OLD.merchant_id != NEW.merchant_id THEN
    SET description = CONCAT(description, 'merchant_id: ', OLD.merchant_id, ' -> ', NEW.merchant_id, '\n');
  END IF;

  IF OLD.merchant_business_name != NEW.merchant_business_name THEN
    SET description = CONCAT(description, 'merchant_business_name: ', OLD.merchant_business_name, ' -> ', NEW.merchant_business_name, '\n');
  END IF;

  IF OLD.merchant_brand_name != NEW.merchant_brand_name THEN
    SET description = CONCAT(description, 'merchant_brand_name: ', OLD.merchant_brand_name, ' -> ', NEW.merchant_brand_name, '\n');
  END IF;
  
  IF OLD.store_id != NEW.store_id THEN
    SET description = CONCAT(description, 'store_id: ', OLD.store_id, ' -> ', NEW.store_id, '\n');
  END IF;
  
  IF OLD.store_business_name != NEW.store_business_name THEN
    SET description = CONCAT(description, 'store_business_name: ', OLD.store_business_name, ' -> ', NEW.store_business_name, '\n');
  END IF;
  
  IF OLD.store_brand_name != NEW.store_brand_name THEN
    SET description = CONCAT(description, 'store_brand_name: ', OLD.store_brand_name, ' -> ', NEW.store_brand_name, '\n');
  END IF;
  
  IF OLD.business_address != NEW.business_address THEN
    SET description = CONCAT(description, 'business_address: ', OLD.business_address, ' -> ', NEW.business_address, '\n');
  END IF;
  
  IF OLD.settlement_period_start != NEW.settlement_period_start THEN
    SET description = CONCAT(description, 'settlement_period_start: ', OLD.settlement_period_start, ' -> ', NEW.settlement_period_start, '\n');
  END IF;
  
  IF OLD.settlement_period_end != NEW.settlement_period_end THEN
    SET description = CONCAT(description, 'settlement_period_end: ', OLD.settlement_period_end, ' -> ', NEW.settlement_period_end, '\n');
  END IF;
  
  IF OLD.settlement_number != NEW.settlement_number THEN
    SET description = CONCAT(description, 'settlement_number: ', OLD.settlement_number, ' -> ', NEW.settlement_number, '\n');
  END IF;
  
  IF OLD.total_successful_orders != NEW.total_successful_orders THEN
    SET description = CONCAT(description, 'total_successful_orders: ', OLD.total_successful_orders, ' -> ', NEW.total_successful_orders, '\n');
  END IF;
  
  IF OLD.total_gross_sales != NEW.total_gross_sales THEN
    SET description = CONCAT(description, 'total_gross_sales: ', OLD.total_gross_sales, ' -> ', NEW.total_gross_sales, '\n');
  END IF;
  
  IF OLD.total_discount != NEW.total_discount THEN
    SET description = CONCAT(description, 'total_discount: ', OLD.total_discount, ' -> ', NEW.total_discount, '\n');
  END IF;
  
  IF OLD.total_outstanding_amount_1 != NEW.total_outstanding_amount_1 THEN
    SET description = CONCAT(description, 'total_outstanding_amount_1: ', OLD.total_outstanding_amount_1, ' -> ', NEW.total_outstanding_amount_1, '\n');
  END IF;
  
  IF OLD.leadgen_commission_rate_base != NEW.leadgen_commission_rate_base THEN
    SET description = CONCAT(description, 'leadgen_commission_rate_base: ', OLD.leadgen_commission_rate_base, ' -> ', NEW.leadgen_commission_rate_base, '\n');
  END IF;
  
  IF OLD.commission_rate != NEW.commission_rate THEN
    SET description = CONCAT(description, 'commission_rate: ', OLD.commission_rate, ' -> ', NEW.commission_rate, '\n');
  END IF;
  
  IF OLD.total_commission_fees_1 != NEW.total_commission_fees_1 THEN
    SET description = CONCAT(description, 'total_commission_fees_1: ', OLD.total_commission_fees_1, ' -> ', NEW.total_commission_fees_1, '\n');
  END IF;
  
  IF OLD.card_payment_pg_fee != NEW.card_payment_pg_fee THEN
    SET description = CONCAT(description, 'card_payment_pg_fee: ', OLD.card_payment_pg_fee, ' -> ', NEW.card_payment_pg_fee, '\n');
  END IF;
  
  IF OLD.paymaya_pg_fee != NEW.paymaya_pg_fee THEN
    SET description = CONCAT(description, 'paymaya_pg_fee: ', OLD.paymaya_pg_fee, ' -> ', NEW.paymaya_pg_fee, '\n');
  END IF;
  
  IF OLD.gcash_miniapp_pg_fee != NEW.gcash_miniapp_pg_fee THEN
    SET description = CONCAT(description, 'gcash_miniapp_pg_fee: ', OLD.gcash_miniapp_pg_fee, ' -> ', NEW.gcash_miniapp_pg_fee, '\n');
  END IF;
  
  IF OLD.gcash_pg_fee != NEW.gcash_pg_fee THEN
    SET description = CONCAT(description, 'gcash_pg_fee: ', OLD.gcash_pg_fee, ' -> ', NEW.gcash_pg_fee, '\n');
  END IF;
  
  IF OLD.total_payment_gateway_fees_1 != NEW.total_payment_gateway_fees_1 THEN
    SET description = CONCAT(description, 'total_payment_gateway_fees_1: ', OLD.total_payment_gateway_fees_1, ' -> ', NEW.total_payment_gateway_fees_1, '\n');
  END IF;
  
  IF OLD.total_outstanding_amount_2 != NEW.total_outstanding_amount_2 THEN
    SET description = CONCAT(description, 'total_outstanding_amount_2: ', OLD.total_outstanding_amount_2, ' -> ', NEW.total_outstanding_amount_2, '\n');
  END IF;
  
  IF OLD.total_commission_fees_2 != NEW.total_commission_fees_2 THEN
    SET description = CONCAT(description, 'total_commission_fees_2: ', OLD.total_commission_fees_2, ' -> ', NEW.total_commission_fees_2, '\n');
  END IF;
  
  IF OLD.total_payment_gateway_fees_2 != NEW.total_payment_gateway_fees_2 THEN
    SET description = CONCAT(description, 'total_payment_gateway_fees_2: ', OLD.total_payment_gateway_fees_2, ' -> ', NEW.total_payment_gateway_fees_2, '\n');
  END IF;
  
  IF OLD.bank_fees != NEW.bank_fees THEN
    SET description = CONCAT(description, 'bank_fees: ', OLD.bank_fees, ' -> ', NEW.bank_fees, '\n');
  END IF;
  
  IF OLD.cwt_from_gross_sales != NEW.cwt_from_gross_sales THEN
    SET description = CONCAT(description, 'cwt_from_gross_sales: ', OLD.cwt_from_gross_sales, ' -> ', NEW.cwt_from_gross_sales, '\n');
  END IF;
  
  IF OLD.cwt_from_transaction_fees != NEW.cwt_from_transaction_fees THEN
    SET description = CONCAT(description, 'cwt_from_transaction_fees: ', OLD.cwt_from_transaction_fees, ' -> ', NEW.cwt_from_transaction_fees, '\n');
  END IF;
  
  IF OLD.cwt_from_pg_fees != NEW.cwt_from_pg_fees THEN
    SET description = CONCAT(description, 'cwt_from_pg_fees: ', OLD.cwt_from_pg_fees, ' -> ', NEW.cwt_from_pg_fees, '\n');
  END IF;
  
  IF OLD.total_amount_paid_out != NEW.total_amount_paid_out THEN
    SET description = CONCAT(description, 'total_amount_paid_out: ', OLD.total_amount_paid_out, ' -> ', NEW.total_amount_paid_out, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_coupled', NEW.coupled_report_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `report_history_decoupled`
--

CREATE TABLE `report_history_decoupled` (
  `decoupled_report_id` varchar(36) NOT NULL,
  `generated_by` varchar(36) DEFAULT NULL,
  `merchant_id` varchar(36) DEFAULT NULL,
  `merchant_business_name` varchar(255) DEFAULT NULL,
  `merchant_brand_name` varchar(255) DEFAULT NULL,
  `store_id` varchar(36) DEFAULT NULL,
  `store_business_name` varchar(255) DEFAULT NULL,
  `store_brand_name` varchar(255) DEFAULT NULL,
  `business_address` text NOT NULL,
  `settlement_period_start` date NOT NULL,
  `settlement_period_end` date NOT NULL,
  `settlement_date` varchar(30) NOT NULL,
  `settlement_number` varchar(20) NOT NULL,
  `settlement_period` varchar(30) NOT NULL,
  `total_successful_orders` int(11) NOT NULL,
  `total_gross_sales` decimal(10,2) NOT NULL,
  `total_discount` decimal(10,2) NOT NULL,
  `total_net_sales` decimal(10,2) NOT NULL,
  `leadgen_commission_rate_base_pretrial` decimal(10,2) NOT NULL,
  `commission_rate_pretrial` varchar(10) NOT NULL,
  `total_pretrial` decimal(10,2) NOT NULL,
  `leadgen_commission_rate_base_billable` decimal(10,2) NOT NULL,
  `commission_rate_billable` varchar(10) NOT NULL,
  `total_billable` decimal(10,2) NOT NULL,
  `total_commission_fees` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `report_history_decoupled`
--

INSERT INTO `report_history_decoupled` (`decoupled_report_id`, `generated_by`, `merchant_id`, `merchant_business_name`, `merchant_brand_name`, `store_id`, `store_business_name`, `store_brand_name`, `business_address`, `settlement_period_start`, `settlement_period_end`, `settlement_date`, `settlement_number`, `settlement_period`, `total_successful_orders`, `total_gross_sales`, `total_discount`, `total_net_sales`, `leadgen_commission_rate_base_pretrial`, `commission_rate_pretrial`, `total_pretrial`, `leadgen_commission_rate_base_billable`, `commission_rate_billable`, `total_billable`, `total_commission_fees`, `created_at`, `updated_at`) VALUES
('157b5bac-31f4-11ef-a30f-0a002700000d', NULL, '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Merchant Legal Name', 'B00KY Demo Merchant', NULL, NULL, NULL, 'Somewhere St.', '2024-05-01', '2024-06-30', 'Jun 24, 2024', '202406-157ab0f9', 'May 1 - Jun 30, 2024', 1, '1800.00', '200.00', '1600.00', '1600.00', '10.00%', '179.20', '0.00', '10.00%', '0.00', '0.00', '2024-06-24 06:36:27', '2024-06-24 06:36:27'),
('27153ce8-31f4-11ef-a30f-0a002700000d', NULL, NULL, NULL, NULL, '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'Demo Legal Name', 'B00KY Demo Store', 'Anywhere St.', '2024-05-01', '2024-06-30', 'Jun 24, 2024', '202406-2713761c', 'May 1 - Jun 30, 2024', 1, '1800.00', '200.00', '1600.00', '1600.00', '10.00%', '179.20', '0.00', '10.00%', '0.00', '0.00', '2024-06-24 06:36:56', '2024-06-24 06:36:56');

--
-- Triggers `report_history_decoupled`
--
DELIMITER $$
CREATE TRIGGER `report_history_decoupled_insert_log` AFTER INSERT ON `report_history_decoupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Decoupled report history record added\n',
  'generated_by: ', IFNULL(NEW.generated_by, 'N/A'), 
  '\n','merchant_id: ', IFNULL(NEW.merchant_id, 'N/A'), 
  '\n','merchant_business_name: ', IFNULL(NEW.merchant_business_name, 'N/A'), 
  '\n','merchant_brand_name: ', IFNULL(NEW.merchant_brand_name, 'N/A'),
  '\n','store_id: ', IFNULL(NEW.store_id, 'N/A'),
  '\n','store_business_name: ', IFNULL(NEW.store_business_name, 'N/A'), 
  '\n','store_brand_name: ', IFNULL(NEW.store_brand_name, 'N/A'),
  '\n','business_address: ', IFNULL(NEW.business_address, 'N/A'),
  '\n','settlement_period_start: ', IFNULL(NEW.settlement_period_start, 'N/A'),
  '\n','settlement_period_end: ', IFNULL(NEW.settlement_period_end, 'N/A'),
  '\n','settlement_date: ', IFNULL(NEW.settlement_date, 'N/A'),
  '\n','settlement_number: ', IFNULL(NEW.settlement_number, 'N/A'),
  '\n','settlement_period: ', IFNULL(NEW.settlement_period, 'N/A'),
                           
  '\n','total_successful_orders: ', IFNULL(NEW.total_successful_orders, 'N/A'),
  '\n','total_gross_sales: ', IFNULL(NEW.total_gross_sales, 'N/A'),
  '\n','total_discount: ', IFNULL(NEW.total_discount, 'N/A'),
  '\n','total_net_sales: ', IFNULL(NEW.total_net_sales, 'N/A'),
  '\n','leadgen_commission_rate_base_pretrial: ', IFNULL(NEW.leadgen_commission_rate_base_pretrial, 'N/A'),
  '\n','commission_rate_pretrial: ', IFNULL(NEW.commission_rate_pretrial, 'N/A'),
  '\n','total_pretrial: ', IFNULL(NEW.total_pretrial, 'N/A'),
  '\n','leadgen_commission_rate_base_billable: ', IFNULL(NEW.leadgen_commission_rate_base_billable, 'N/A'),
  '\n','commission_rate_billable: ', IFNULL(NEW.commission_rate_billable, 'N/A'),
  '\n','total_billable: ', IFNULL(NEW.total_billable, 'N/A'),
  '\n','total_commission_fees: ', IFNULL(NEW.total_commission_fees, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_coupled', NEW.decoupled_report_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `report_history_decoupled_update_log` AFTER UPDATE ON `report_history_decoupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Decoupled report history record updated\n';

  IF OLD.generated_by != NEW.generated_by THEN
    SET description = CONCAT(description, 'generated_by: ', OLD.generated_by, ' -> ', NEW.generated_by, '\n');
  END IF;

  IF OLD.merchant_id != NEW.merchant_id THEN
    SET description = CONCAT(description, 'merchant_id: ', OLD.merchant_id, ' -> ', NEW.merchant_id, '\n');
  END IF;

  IF OLD.merchant_business_name != NEW.merchant_business_name THEN
    SET description = CONCAT(description, 'merchant_business_name: ', OLD.merchant_business_name, ' -> ', NEW.merchant_business_name, '\n');
  END IF;

  IF OLD.merchant_brand_name != NEW.merchant_brand_name THEN
    SET description = CONCAT(description, 'merchant_brand_name: ', OLD.merchant_brand_name, ' -> ', NEW.merchant_brand_name, '\n');
  END IF;
  
  IF OLD.store_id != NEW.store_id THEN
    SET description = CONCAT(description, 'store_id: ', OLD.store_id, ' -> ', NEW.store_id, '\n');
  END IF;
  
  IF OLD.store_business_name != NEW.store_business_name THEN
    SET description = CONCAT(description, 'store_business_name: ', OLD.store_business_name, ' -> ', NEW.store_business_name, '\n');
  END IF;
  
  IF OLD.store_brand_name != NEW.store_brand_name THEN
    SET description = CONCAT(description, 'store_brand_name: ', OLD.store_brand_name, ' -> ', NEW.store_brand_name, '\n');
  END IF;
  
  IF OLD.business_address != NEW.business_address THEN
    SET description = CONCAT(description, 'business_address: ', OLD.business_address, ' -> ', NEW.business_address, '\n');
  END IF;
  
  IF OLD.settlement_period_start != NEW.settlement_period_start THEN
    SET description = CONCAT(description, 'settlement_period_start: ', OLD.settlement_period_start, ' -> ', NEW.settlement_period_start, '\n');
  END IF;
  
  IF OLD.settlement_period_end != NEW.settlement_period_end THEN
    SET description = CONCAT(description, 'settlement_period_end: ', OLD.settlement_period_end, ' -> ', NEW.settlement_period_end, '\n');
  END IF;
  
  IF OLD.settlement_date != NEW.settlement_date THEN
    SET description = CONCAT(description, 'settlement_date: ', OLD.settlement_date, ' -> ', NEW.settlement_date, '\n');
  END IF;
  
  IF OLD.settlement_number != NEW.settlement_number THEN
    SET description = CONCAT(description, 'settlement_number: ', OLD.settlement_number, ' -> ', NEW.settlement_number, '\n');
  END IF;
  
  IF OLD.settlement_period != NEW.settlement_period THEN
    SET description = CONCAT(description, 'settlement_period: ', OLD.settlement_period, ' -> ', NEW.settlement_period, '\n');
  END IF;
  
  IF OLD.total_successful_orders != NEW.total_successful_orders THEN
    SET description = CONCAT(description, 'total_successful_orders: ', OLD.total_successful_orders, ' -> ', NEW.total_successful_orders, '\n');
  END IF;
  
  IF OLD.total_gross_sales != NEW.total_gross_sales THEN
    SET description = CONCAT(description, 'total_gross_sales: ', OLD.total_gross_sales, ' -> ', NEW.total_gross_sales, '\n');
  END IF;
  
  IF OLD.total_discount != NEW.total_discount THEN
    SET description = CONCAT(description, 'total_discount: ', OLD.total_discount, ' -> ', NEW.total_discount, '\n');
  END IF;
  
  IF OLD.total_net_sales != NEW.total_net_sales THEN
    SET description = CONCAT(description, 'total_net_sales: ', OLD.total_net_sales, ' -> ', NEW.total_net_sales, '\n');
  END IF;
  
  IF OLD.leadgen_commission_rate_base_pretrial != NEW.leadgen_commission_rate_base_pretrial THEN
    SET description = CONCAT(description, 'leadgen_commission_rate_base_pretrial: ', OLD.leadgen_commission_rate_base_pretrial, ' -> ', NEW.leadgen_commission_rate_base_pretrial, '\n');
  END IF;
  
  IF OLD.commission_rate_pretrial != NEW.commission_rate_pretrial THEN
    SET description = CONCAT(description, 'commission_rate_pretrial: ', OLD.commission_rate_pretrial, ' -> ', NEW.commission_rate_pretrial, '\n');
  END IF;
  
  IF OLD.total_pretrial != NEW.total_pretrial THEN
    SET description = CONCAT(description, 'total_pretrial: ', OLD.total_pretrial, ' -> ', NEW.total_pretrial, '\n');
  END IF;

  IF OLD.leadgen_commission_rate_base_billable != NEW.leadgen_commission_rate_base_billable THEN
    SET description = CONCAT(description, 'leadgen_commission_rate_base_billable: ', OLD.leadgen_commission_rate_base_billable, ' -> ', NEW.leadgen_commission_rate_base_billable, '\n');
  END IF;
  
  IF OLD.commission_rate_billable != NEW.commission_rate_billable THEN
    SET description = CONCAT(description, 'commission_rate_billable: ', OLD.commission_rate_billable, ' -> ', NEW.commission_rate_billable, '\n');
  END IF;
  
  IF OLD.total_billable != NEW.total_billable THEN
    SET description = CONCAT(description, 'total_billable: ', OLD.total_billable, ' -> ', NEW.total_billable, '\n');
  END IF;

  IF OLD.total_commission_fees != NEW.total_commission_fees THEN
    SET description = CONCAT(description, 'total_commission_fees: ', OLD.total_commission_fees, ' -> ', NEW.total_commission_fees, '\n');
  END IF;
    
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_decoupled', NEW.decoupled_report_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `report_history_gcash_body`
--

CREATE TABLE `report_history_gcash_body` (
  `gcash_report_body_id` varchar(36) NOT NULL,
  `gcash_report_id` varchar(36) NOT NULL,
  `item` varchar(100) NOT NULL,
  `quantity_redeemed` int(11) NOT NULL,
  `net_amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `report_history_gcash_body`
--

INSERT INTO `report_history_gcash_body` (`gcash_report_body_id`, `gcash_report_id`, `item`, `quantity_redeemed`, `net_amount`, `created_at`, `updated_at`) VALUES
('2bb7a111-31fb-11ef-a30f-0a002700000d', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'B00KYDEMO', 2, '16460.00', '2024-06-24 07:27:11', '2024-06-24 07:27:11'),
('2bb7febc-31fb-11ef-a30f-0a002700000d', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'GCA5H', 1, '1600.00', '2024-06-24 07:27:11', '2024-06-24 07:27:11'),
('d4526d35-31fb-11ef-a30f-0a002700000d', 'd4502354-31fb-11ef-a30f-0a002700000d', 'B00KYDEMO', 2, '16460.00', '2024-06-24 07:31:54', '2024-06-24 07:31:54'),
('d4528b14-31fb-11ef-a30f-0a002700000d', 'd4502354-31fb-11ef-a30f-0a002700000d', 'GCA5H', 1, '1600.00', '2024-06-24 07:31:54', '2024-06-24 07:31:54');

--
-- Triggers `report_history_gcash_body`
--
DELIMITER $$
CREATE TRIGGER `generate_gcash_report_body_id` BEFORE INSERT ON `report_history_gcash_body` FOR EACH ROW BEGIN
    SET NEW.gcash_report_body_id = UUID();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `report_history_gcash_body_insert_log` AFTER INSERT ON `report_history_gcash_body` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Gcash report history body record added\n',
  'gcash_report_id: ', IFNULL(NEW.gcash_report_id, 'N/A'), 
  '\n','item: ', IFNULL(NEW.item, 'N/A'), 
  '\n','quantity_redeemed: ', IFNULL(NEW.quantity_redeemed, 'N/A'), 
  '\n','net_amount: ', IFNULL(NEW.net_amount, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_body', NEW.gcash_report_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `report_history_gcash_body_update_log` AFTER UPDATE ON `report_history_gcash_body` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Gcash report history body record updated\n';

  IF OLD.gcash_report_id != NEW.gcash_report_id THEN
    SET description = CONCAT(description, 'gcash_report_id: ', OLD.gcash_report_id, ' -> ', NEW.gcash_report_id, '\n');
  END IF;

  IF OLD.item != NEW.item THEN
    SET description = CONCAT(description, 'item: ', OLD.item, ' -> ', NEW.item, '\n');
  END IF;

  IF OLD.quantity_redeemed != NEW.quantity_redeemed THEN
    SET description = CONCAT(description, 'quantity_redeemed: ', OLD.quantity_redeemed, ' -> ', NEW.quantity_redeemed, '\n');
  END IF;

  IF OLD.net_amount != NEW.net_amount THEN
    SET description = CONCAT(description, 'net_amount: ', OLD.net_amount, ' -> ', NEW.net_amount, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_body', NEW.gcash_report_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `report_history_gcash_head`
--

CREATE TABLE `report_history_gcash_head` (
  `gcash_report_id` varchar(36) NOT NULL,
  `generated_by` varchar(36) DEFAULT NULL,
  `merchant_id` varchar(36) DEFAULT NULL,
  `merchant_business_name` varchar(255) DEFAULT NULL,
  `merchant_brand_name` varchar(255) DEFAULT NULL,
  `store_id` varchar(36) DEFAULT NULL,
  `store_business_name` varchar(255) DEFAULT NULL,
  `store_brand_name` varchar(255) DEFAULT NULL,
  `business_address` text NOT NULL,
  `settlement_period_start` date NOT NULL,
  `settlement_period_end` date NOT NULL,
  `settlement_date` varchar(30) NOT NULL,
  `settlement_number` varchar(20) NOT NULL,
  `settlement_period` varchar(30) NOT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `commission_rate` varchar(10) DEFAULT NULL,
  `commission_amount` decimal(10,2) DEFAULT NULL,
  `vat_amount` decimal(10,2) DEFAULT NULL,
  `total_commission_fees` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `report_history_gcash_head`
--

INSERT INTO `report_history_gcash_head` (`gcash_report_id`, `generated_by`, `merchant_id`, `merchant_business_name`, `merchant_brand_name`, `store_id`, `store_business_name`, `store_brand_name`, `business_address`, `settlement_period_start`, `settlement_period_end`, `settlement_date`, `settlement_number`, `settlement_period`, `total_amount`, `commission_rate`, `commission_amount`, `vat_amount`, `total_commission_fees`, `created_at`, `updated_at`) VALUES
('2bb4d85b-31fb-11ef-a30f-0a002700000d', NULL, '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Merchant Legal Name', 'B00KY Demo Merchant', NULL, NULL, NULL, 'Somewhere St.', '2024-05-01', '2024-06-30', 'Jun 24, 2024', '202406-2bb4d85b', 'May 1 - Jun 30, 2024', '18060.00', '10.00%', '1806.00', '216.72', '2022.72', '2024-06-24 07:27:11', '2024-06-24 07:27:11'),
('d4502354-31fb-11ef-a30f-0a002700000d', NULL, NULL, NULL, NULL, '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'Demo Legal Name', 'B00KY Demo Store', 'Anywhere St.', '2024-05-01', '2024-06-30', 'Jun 24, 2024', '202406-d4502354', 'May 1 - Jun 30, 2024', '18060.00', '10.00%', '1806.00', '216.72', '2022.72', '2024-06-24 07:31:54', '2024-06-24 07:31:54');

--
-- Triggers `report_history_gcash_head`
--
DELIMITER $$
CREATE TRIGGER `report_history_gcash_head_insert_log` AFTER INSERT ON `report_history_gcash_head` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Gcash report history head record added\n',
  'generated_by: ', IFNULL(NEW.generated_by, 'N/A'), 
  '\n','merchant_id: ', IFNULL(NEW.merchant_id, 'N/A'), 
  '\n','merchant_business_name: ', IFNULL(NEW.merchant_business_name, 'N/A'), 
  '\n','merchant_brand_name: ', IFNULL(NEW.merchant_brand_name, 'N/A'),
  '\n','store_id: ', IFNULL(NEW.store_id, 'N/A'),
  '\n','store_business_name: ', IFNULL(NEW.store_business_name, 'N/A'), 
  '\n','store_brand_name: ', IFNULL(NEW.store_brand_name, 'N/A'),
  '\n','business_address: ', IFNULL(NEW.business_address, 'N/A'),
  '\n','settlement_period_start: ', IFNULL(NEW.settlement_period_start, 'N/A'),
  '\n','settlement_period_end: ', IFNULL(NEW.settlement_period_end, 'N/A'),
  '\n','settlement_date: ', IFNULL(NEW.settlement_date, 'N/A'),
  '\n','settlement_number: ', IFNULL(NEW.settlement_number, 'N/A'),
  '\n','settlement_period: ', IFNULL(NEW.settlement_period, 'N/A'),
  '\n','total_amount: ', IFNULL(NEW.total_amount, 'N/A'),
  '\n','commission_rate: ', IFNULL(NEW.commission_rate, 'N/A'),
  '\n','vat_amount: ', IFNULL(NEW.vat_amount, 'N/A'),
  '\n','total_commission_fees: ', IFNULL(NEW.total_commission_fees, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_head', NEW.gcash_report_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `report_history_gcash_head_update_log` AFTER UPDATE ON `report_history_gcash_head` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Gcash report history head record updated\n';

  IF OLD.generated_by != NEW.generated_by THEN
    SET description = CONCAT(description, 'generated_by: ', OLD.generated_by, ' -> ', NEW.generated_by, '\n');
  END IF;

  IF OLD.merchant_id != NEW.merchant_id THEN
    SET description = CONCAT(description, 'merchant_id: ', OLD.merchant_id, ' -> ', NEW.merchant_id, '\n');
  END IF;

  IF OLD.merchant_business_name != NEW.merchant_business_name THEN
    SET description = CONCAT(description, 'merchant_business_name: ', OLD.merchant_business_name, ' -> ', NEW.merchant_business_name, '\n');
  END IF;

  IF OLD.merchant_brand_name != NEW.merchant_brand_name THEN
    SET description = CONCAT(description, 'merchant_brand_name: ', OLD.merchant_brand_name, ' -> ', NEW.merchant_brand_name, '\n');
  END IF;
  
  IF OLD.store_id != NEW.store_id THEN
    SET description = CONCAT(description, 'store_id: ', OLD.store_id, ' -> ', NEW.store_id, '\n');
  END IF;
  
  IF OLD.store_business_name != NEW.store_business_name THEN
    SET description = CONCAT(description, 'store_business_name: ', OLD.store_business_name, ' -> ', NEW.store_business_name, '\n');
  END IF;
  
  IF OLD.store_brand_name != NEW.store_brand_name THEN
    SET description = CONCAT(description, 'store_brand_name: ', OLD.store_brand_name, ' -> ', NEW.store_brand_name, '\n');
  END IF;
  
  IF OLD.business_address != NEW.business_address THEN
    SET description = CONCAT(description, 'business_address: ', OLD.business_address, ' -> ', NEW.business_address, '\n');
  END IF;
  
  IF OLD.settlement_period_start != NEW.settlement_period_start THEN
    SET description = CONCAT(description, 'settlement_period_start: ', OLD.settlement_period_start, ' -> ', NEW.settlement_period_start, '\n');
  END IF;
  
  IF OLD.settlement_period_end != NEW.settlement_period_end THEN
    SET description = CONCAT(description, 'settlement_period_end: ', OLD.settlement_period_end, ' -> ', NEW.settlement_period_end, '\n');
  END IF;
  
  IF OLD.settlement_date != NEW.settlement_date THEN
    SET description = CONCAT(description, 'settlement_date: ', OLD.settlement_date, ' -> ', NEW.settlement_date, '\n');
  END IF;
  
  IF OLD.settlement_number != NEW.settlement_number THEN
    SET description = CONCAT(description, 'settlement_number: ', OLD.settlement_number, ' -> ', NEW.settlement_number, '\n');
  END IF;
  
  IF OLD.settlement_period != NEW.settlement_period THEN
    SET description = CONCAT(description, 'settlement_period: ', OLD.settlement_period, ' -> ', NEW.settlement_period, '\n');
  END IF;
  
  IF OLD.total_amount != NEW.total_amount THEN
    SET description = CONCAT(description, 'total_amount: ', OLD.total_amount, ' -> ', NEW.total_amount, '\n');
  END IF;
  
  IF OLD.commission_rate != NEW.commission_rate THEN
    SET description = CONCAT(description, 'commission_rate: ', OLD.commission_rate, ' -> ', NEW.commission_rate, '\n');
  END IF;
  
  IF OLD.vat_amount != NEW.vat_amount THEN
    SET description = CONCAT(description, 'vat_amount: ', OLD.vat_amount, ' -> ', NEW.vat_amount, '\n');
  END IF;
  
  IF OLD.total_commission_fees != NEW.total_commission_fees THEN
    SET description = CONCAT(description, 'total_commission_fees: ', OLD.total_commission_fees, ' -> ', NEW.total_commission_fees, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_head', NEW.gcash_report_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `store`
--

CREATE TABLE `store` (
  `store_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `store_name` varchar(100) NOT NULL,
  `legal_entity_name` varchar(100) DEFAULT NULL,
  `store_address` varchar(250) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `store`
--

INSERT INTO `store` (`store_id`, `merchant_id`, `store_name`, `legal_entity_name`, `store_address`, `created_at`, `updated_at`) VALUES
('8946759b-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B00KY Demo Store', 'Demo Legal Name', 'Anywhere St.', '2024-05-28 07:18:52', '2024-06-04 02:56:04');

--
-- Triggers `store`
--
DELIMITER $$
CREATE TRIGGER `generate_store_id` BEFORE INSERT ON `store` FOR EACH ROW BEGIN
    IF NEW.store_id IS NULL OR NEW.store_id = '' THEN
        SET NEW.store_id = UUID();
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `store_insert_log` AFTER INSERT ON `store` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Store record added\n',
  'merchant_id: ', IFNULL(NEW.merchant_id, 'N/A'), 
  '\n','store_name: ', IFNULL(NEW.store_name, 'N/A'), 
  '\n','legal_entity_name: ', IFNULL(NEW.legal_entity_name, 'N/A'), 
  '\n','store_address: ', IFNULL(NEW.store_address, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('store', NEW.store_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `store_update_log` AFTER UPDATE ON `store` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Store record updated\n';

  IF OLD.merchant_id != NEW.merchant_id THEN
    SET description = CONCAT(description, 'merchant_id: ', OLD.merchant_id, ' -> ', NEW.merchant_id, '\n');
  END IF;

  IF OLD.store_name != NEW.store_name THEN
    SET description = CONCAT(description, 'store_name: ', OLD.store_name, ' -> ', NEW.store_name, '\n');
  END IF;

  IF OLD.legal_entity_name != NEW.legal_entity_name THEN
    SET description = CONCAT(description, 'legal_entity_name: ', OLD.legal_entity_name, ' -> ', NEW.legal_entity_name, '\n');
  END IF;

  IF OLD.store_address != NEW.store_address THEN
    SET description = CONCAT(description, 'store_address: ', OLD.store_address, ' -> ', NEW.store_address, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('store', NEW.store_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `transaction_id` varchar(36) NOT NULL,
  `store_id` varchar(36) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `customer_id` varchar(14) NOT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `transaction_date` datetime NOT NULL,
  `gross_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `amount_discounted` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya') DEFAULT NULL,
  `bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`transaction_id`, `store_id`, `promo_code`, `customer_id`, `customer_name`, `transaction_date`, `gross_amount`, `discount`, `amount_discounted`, `payment`, `bill_status`, `created_at`, `updated_at`) VALUES
('1bc0f5fe-224b-11ef-b01f-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'B00KYDEMO', '\"639121234345\"', 'Maria Demo', '2024-05-15 16:17:58', '20760.00', '5190.00', '15570.00', 'gcash', 'BILLABLE', '2024-06-01 08:17:58', '2024-06-05 03:42:49'),
('8d1552bf-1cc3-11ef-8abb-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'B00KYDEMO', '\"639123456789\"', 'Juan Person', '2024-05-28 09:25:43', '1484.00', '594.00', '890.00', 'gcash', 'PRE-TRIAL', '2024-05-28 07:26:08', '2024-05-28 07:26:08'),
('a6673ec0-2d50-11ef-a4d2-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'GCA5H', '\"638572947601\"', 'Custom Er', '2024-05-18 10:55:41', '1800.00', '200.00', '1600.00', 'gcash', 'PRE-TRIAL', '2024-06-18 08:56:28', '2024-06-18 08:56:28'),
('e881c2e7-224a-11ef-b01f-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'B00KYDEMO', '\"639987654321\"', 'Anya Human', '2024-06-06 10:16:20', '15570.00', '3114.00', '12456.00', 'paymaya_credit_card', 'PRE-TRIAL', '2024-06-04 08:17:39', '2024-06-04 08:17:39');

--
-- Triggers `transaction`
--
DELIMITER $$
CREATE TRIGGER `generate_transaction_id` BEFORE INSERT ON `transaction` FOR EACH ROW BEGIN
    IF NEW.transaction_id IS NULL THEN
        SET NEW.transaction_id = UUID();
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `transaction_insert_log` AFTER INSERT ON `transaction` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Transaction record added\n',
  'store_id: ', IFNULL(NEW.store_id, 'N/A'), 
  '\n','promo_code: ', IFNULL(NEW.promo_code, 'N/A'), 
  '\n','customer_id: ', IFNULL(NEW.customer_id, 'N/A'), 
  '\n','transaction_date: ', IFNULL(NEW.transaction_date, 'N/A'),
  '\n','gross_amount: ', IFNULL(NEW.gross_amount, 'N/A'), 
  '\n','discount: ', IFNULL(NEW.discount, 'N/A'), 
  '\n','amount_discounted: ', IFNULL(NEW.amount_discounted, 'N/A'), 
  '\n','payment: ', IFNULL(NEW.payment, 'N/A'), 
  '\n','bill_status: ', IFNULL(NEW.bill_status, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('transaction', NEW.transaction_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `transaction_update_log` AFTER UPDATE ON `transaction` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Transaction record updated\n';

  IF OLD.store_id != NEW.store_id THEN
    SET description = CONCAT(description, 'store_id: ', OLD.store_id, ' -> ', NEW.store_id, '\n');
  END IF;

  IF OLD.promo_code != NEW.promo_code THEN
    SET description = CONCAT(description, 'promo_code: ', OLD.promo_code, ' -> ', NEW.promo_code, '\n');
  END IF;

  IF OLD.customer_id != NEW.customer_id THEN
    SET description = CONCAT(description, 'customer_id: ', OLD.customer_id, ' -> ', NEW.customer_id, '\n');
  END IF;

  IF OLD.transaction_date != NEW.transaction_date THEN
    SET description = CONCAT(description, 'transaction_date: ', OLD.transaction_date, ' -> ', NEW.transaction_date, '\n');
  END IF;

  IF OLD.gross_amount != NEW.gross_amount THEN
    SET description = CONCAT(description, 'gross_amount: ', OLD.gross_amount, ' -> ', NEW.gross_amount, '\n');
  END IF;

  IF OLD.discount != NEW.discount THEN
    SET description = CONCAT(description, 'discount: ', OLD.discount, ' -> ', NEW.discount, '\n');
  END IF;

  IF OLD.amount_discounted != NEW.amount_discounted THEN
    SET description = CONCAT(description, 'amount_discounted: ', OLD.amount_discounted, ' -> ', NEW.amount_discounted, '\n');
  END IF;

  IF OLD.payment != NEW.payment THEN
    SET description = CONCAT(description, 'payment: ', OLD.payment, ' -> ', NEW.payment, '\n');
  END IF;

  IF OLD.bill_status != NEW.bill_status THEN
    SET description = CONCAT(description, 'bill_status: ', OLD.bill_status, ' -> ', NEW.bill_status, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('transaction', NEW.transaction_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `transaction_summary_view`
-- (See below for the actual view)
--
CREATE TABLE `transaction_summary_view` (
`Transaction ID` varchar(8)
,`Transaction Date` datetime
,`Merchant ID` varchar(36)
,`Merchant Name` varchar(255)
,`Store ID` varchar(36)
,`Store Name` varchar(100)
,`Customer ID` varchar(14)
,`Customer Name` varchar(100)
,`Promo Code` varchar(100)
,`Voucher Type` enum('Coupled','Decoupled')
,`Promo Category` enum('Grab & Go','Casual Dining')
,`Promo Group` enum('Booky','Gcash','Unionbank','Gcash/Booky','UB/Booky')
,`Promo Type` varchar(255)
,`Gross Amount` decimal(10,2)
,`Discount` decimal(10,2)
,`Net Amount` decimal(11,2)
,`Payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya')
,`Bill Status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE')
,`Commission Type` varchar(50)
,`Commission Rate` varchar(51)
,`Commission Amount` double(19,2)
,`Total Billing` double(19,2)
,`PG Fee Rate` varchar(51)
,`PG Fee Amount` double(19,2)
,`Amount to be Disbursed` double(19,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` varchar(36) NOT NULL,
  `email_address` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('Admin','User') NOT NULL DEFAULT 'User',
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Inactive',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `email_address`, `password`, `name`, `type`, `status`, `created_at`, `updated_at`) VALUES
('3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'admin@bookymail.ph', 'admin123booky', 'Booky Admin', 'Admin', 'Active', '2024-05-31 07:41:48', '2024-05-31 07:41:48'),
('6b8a15bf-2ed7-11ef-bafd-48e7dad87c24', 'cookie@booky.ph', '$2y$10$xXT7USa7PPtpQJm4g1xq8O..A2cKtV4/YbW.aJiKx0R2fobDZUa3m', 'Cookie', 'User', 'Inactive', '2024-06-20 07:33:42', '2024-06-20 07:33:42');

--
-- Triggers `user`
--
DELIMITER $$
CREATE TRIGGER `generate_user_id` BEFORE INSERT ON `user` FOR EACH ROW BEGIN
    SET NEW.user_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `user_insert_log` AFTER INSERT ON `user` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('User record added\n',
  'email_address: ', IFNULL(NEW.email_address, 'N/A'), 
  '\n','password: ', IFNULL(NEW.password, 'N/A'), 
  '\n','name: ', IFNULL(NEW.name, 'N/A'), 
  '\n','type: ', IFNULL(NEW.type, 'N/A'),
  '\n','status: ', IFNULL(NEW.status, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('user', NEW.user_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `user_update_log` AFTER UPDATE ON `user` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'User record updated\n';

  IF OLD.email_address != NEW.email_address THEN
    SET description = CONCAT(description, 'email_address: ', OLD.email_address, ' -> ', NEW.email_address, '\n');
  END IF;

  IF OLD.password != NEW.password THEN
    SET description = CONCAT(description, 'password: ', OLD.password, ' -> ', NEW.password, '\n');
  END IF;

  IF OLD.name != NEW.name THEN
    SET description = CONCAT(description, 'name: ', OLD.name, ' -> ', NEW.name, '\n');
  END IF;

  IF OLD.type != NEW.type THEN
    SET description = CONCAT(description, 'type: ', OLD.type, ' -> ', NEW.type, '\n');
  END IF;
  
  IF OLD.status != NEW.status THEN
    SET description = CONCAT(description, 'status: ', OLD.status, ' -> ', NEW.status, '\n');
  END IF;

  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('user', NEW.user_id, 'Update', description);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure for view `transaction_summary_view`
--
DROP TABLE IF EXISTS `transaction_summary_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_summary_view`  AS SELECT substr(`t`.`transaction_id`,1,8) AS `Transaction ID`, `t`.`transaction_date` AS `Transaction Date`, `m`.`merchant_id` AS `Merchant ID`, `m`.`merchant_name` AS `Merchant Name`, `s`.`store_id` AS `Store ID`, `s`.`store_name` AS `Store Name`, `t`.`customer_id` AS `Customer ID`, `t`.`customer_name` AS `Customer Name`, `p`.`promo_code` AS `Promo Code`, `p`.`voucher_type` AS `Voucher Type`, `p`.`promo_category` AS `Promo Category`, `p`.`promo_group` AS `Promo Group`, `p`.`promo_type` AS `Promo Type`, `t`.`gross_amount` AS `Gross Amount`, `t`.`discount` AS `Discount`, round(`t`.`gross_amount` - `t`.`discount`,2) AS `Net Amount`, `t`.`payment` AS `Payment`, `t`.`bill_status` AS `Bill Status`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) AS `Commission Type`, coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`lead_gen_commission`,'%')) AS `Commission Rate`, round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100,2) AS `Commission Amount`, CASE WHEN coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` AND `fh`.`column_name` = 'commission_type' AND `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Exc' THEN round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100 * 1.12,2) WHEN coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` AND `fh`.`column_name` = 'commission_type' AND `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Inc' THEN round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100,2) END AS `Total Billing`, CASE WHEN `t`.`payment` = 'paymaya_credit_card' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya_credit_card' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`paymaya_credit_card`,'%'))) WHEN `t`.`payment` = 'gcash' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`gcash`,'%'))) WHEN `t`.`payment` = 'gcash_miniapp' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash_miniapp' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`gcash_miniapp`,'%'))) WHEN `t`.`payment` = 'paymaya' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`paymaya`,'%'))) WHEN `t`.`payment` = 'maya_checkout' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya_checkout' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`maya_checkout`,'%'))) WHEN `t`.`payment` = 'maya' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`maya`,'%'))) END AS `PG Fee Rate`, CASE WHEN `t`.`payment` = 'paymaya_credit_card' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya_credit_card' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya_credit_card`)) / 100,2) WHEN `t`.`payment` = 'gcash' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash`)) / 100,2) WHEN `t`.`payment` = 'gcash_miniapp' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash_miniapp' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash_miniapp`)) / 100,2) WHEN `t`.`payment` = 'paymaya' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya`)) / 100,2) WHEN `t`.`payment` = 'maya_checkout' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya_checkout' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya_checkout`)) / 100,2) WHEN `t`.`payment` = 'maya' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya`)) / 100,2) END AS `PG Fee Amount`, round(`t`.`amount_discounted` - case when coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Exc' then round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100 * 1.12,2) when coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Inc' then round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100,2) end - case when `t`.`payment` = 'paymaya_credit_card' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya_credit_card' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya_credit_card`)) / 100,2) when `t`.`payment` = 'gcash' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash`)) / 100,2) when `t`.`payment` = 'gcash_miniapp' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash_miniapp' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash_miniapp`)) / 100,2) when `t`.`payment` = 'paymaya' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya`)) / 100,2) when `t`.`payment` = 'maya_checkout' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya_checkout' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya_checkout`)) / 100,2) when `t`.`payment` = 'maya' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya`)) / 100,2) end,2) AS `Amount to be Disbursed` FROM ((((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `promo` `p` on(`p`.`promo_code` = `t`.`promo_code`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`)) ORDER BY `t`.`transaction_date` ASC  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_history`
--
ALTER TABLE `activity_history`
  ADD PRIMARY KEY (`activity_id`),
  ADD KEY `activity_history_ibfk_1` (`user_id`);

--
-- Indexes for table `fee`
--
ALTER TABLE `fee`
  ADD PRIMARY KEY (`fee_id`),
  ADD KEY `fee_ibfk_1` (`merchant_id`);

--
-- Indexes for table `fee_history`
--
ALTER TABLE `fee_history`
  ADD PRIMARY KEY (`fee_history_id`),
  ADD KEY `fee_history_ibfk_1` (`fee_id`);

--
-- Indexes for table `merchant`
--
ALTER TABLE `merchant`
  ADD PRIMARY KEY (`merchant_id`);

--
-- Indexes for table `promo`
--
ALTER TABLE `promo`
  ADD PRIMARY KEY (`promo_code`) USING BTREE,
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `promo_history`
--
ALTER TABLE `promo_history`
  ADD PRIMARY KEY (`promo_history_id`),
  ADD KEY `promo_history_ibfk_1` (`promo_code`);

--
-- Indexes for table `report_history_coupled`
--
ALTER TABLE `report_history_coupled`
  ADD PRIMARY KEY (`coupled_report_id`),
  ADD KEY `settlement_report_history_ibfk1` (`merchant_id`),
  ADD KEY `settlement_report_history_ibfk2` (`generated_by`),
  ADD KEY `settlement_report_history_ibfk3` (`store_id`);

--
-- Indexes for table `report_history_decoupled`
--
ALTER TABLE `report_history_decoupled`
  ADD PRIMARY KEY (`decoupled_report_id`);

--
-- Indexes for table `report_history_gcash_body`
--
ALTER TABLE `report_history_gcash_body`
  ADD PRIMARY KEY (`gcash_report_body_id`),
  ADD KEY `report_history_gcash_body_ibfk_1` (`gcash_report_id`);

--
-- Indexes for table `report_history_gcash_head`
--
ALTER TABLE `report_history_gcash_head`
  ADD PRIMARY KEY (`gcash_report_id`),
  ADD KEY `settlement_report_history_gcash_ibfk_1` (`generated_by`),
  ADD KEY `settlement_report_history_gcash_ibfk_2` (`merchant_id`),
  ADD KEY `settlement_report_history_gcash_ibfk_3` (`store_id`);

--
-- Indexes for table `store`
--
ALTER TABLE `store`
  ADD PRIMARY KEY (`store_id`),
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `store_id` (`store_id`),
  ADD KEY `transaction_ibfk_2` (`promo_code`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_history`
--
ALTER TABLE `activity_history`
  ADD CONSTRAINT `activity_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `fee`
--
ALTER TABLE `fee`
  ADD CONSTRAINT `fee_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `fee_history`
--
ALTER TABLE `fee_history`
  ADD CONSTRAINT `fee_history_ibfk_1` FOREIGN KEY (`fee_id`) REFERENCES `fee` (`fee_id`);

--
-- Constraints for table `promo`
--
ALTER TABLE `promo`
  ADD CONSTRAINT `promo_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `promo_history`
--
ALTER TABLE `promo_history`
  ADD CONSTRAINT `promo_history_ibfk_1` FOREIGN KEY (`promo_code`) REFERENCES `promo` (`promo_code`);

--
-- Constraints for table `report_history_coupled`
--
ALTER TABLE `report_history_coupled`
  ADD CONSTRAINT `settlement_report_history_ibfk1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`),
  ADD CONSTRAINT `settlement_report_history_ibfk2` FOREIGN KEY (`generated_by`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `settlement_report_history_ibfk3` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`);

--
-- Constraints for table `report_history_gcash_body`
--
ALTER TABLE `report_history_gcash_body`
  ADD CONSTRAINT `report_history_gcash_body_ibfk_1` FOREIGN KEY (`gcash_report_id`) REFERENCES `report_history_gcash_head` (`gcash_report_id`);

--
-- Constraints for table `report_history_gcash_head`
--
ALTER TABLE `report_history_gcash_head`
  ADD CONSTRAINT `report_history_gcash_head_ibfk_1` FOREIGN KEY (`generated_by`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `report_history_gcash_head_ibfk_2` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`),
  ADD CONSTRAINT `report_history_gcash_head_ibfk_3` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`);

--
-- Constraints for table `store`
--
ALTER TABLE `store`
  ADD CONSTRAINT `store_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`),
  ADD CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`promo_code`) REFERENCES `promo` (`promo_code`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
