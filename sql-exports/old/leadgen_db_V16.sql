-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 13, 2024 at 10:57 AM
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

    SET @sql_insert = CONCAT('INSERT INTO settlement_report_history_coupled 
        (coupled_report_id, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_number, total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, leadgen_commission_rate_base, commission_rate, total_commission_fees_1, paymaya_pg_fee, paymaya_credit_card_pg_fee, maya_pg_fee, maya_checkout_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, cwt_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees,total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
	    `Merchant ID` AS merchant_id, 
            merchant.legal_entity_name AS merchant_business_name, 
            `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
            SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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
	CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
        COUNT(`Transaction ID`) AS total_successful_orders,
        SUM(`Gross Amount`) AS total_gross_sales,
        SUM(`Discount`) AS total_discount,
        SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
        SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
        `Commission Rate` AS commission_rate,
        CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_1,

        SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
        SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
        SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,

	SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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
    GROUP BY 
        `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_merchant_decoupled_report` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    DECLARE v_commission_rate DECIMAL(10,2); -- Adjust the data type as per your needs
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO settlement_report_history_decoupled
        (decoupled_report_id, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_number, total_successful_orders, total_gross_sales, total_discount, total_net_sales, leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id,
            `Merchant ID` AS merchant_id,
            merchant.legal_entity_name AS merchant_business_name,
	    `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
            
	    COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_pretrial,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Promo Fulfillment Type` = ''Decoupled''
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
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_pretrial,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Promo Fulfillment Type` = ''Decoupled''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_store_coupled_report` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO settlement_report_history_coupled 
        (coupled_report_id, store_id, store_business_name, store_brand_name, address, settlement_period_start, settlement_period_end, total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, leadgen_commission_rate_base, commission_rate, total_commission_fees_1, paymaya_pg_fee, paymaya_credit_card_pg_fee, maya_pg_fee, maya_checkout_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, cwt_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees,total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
	    `Store ID` AS store_id, 
            store.legal_entity_name AS store_business_name, 
            `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
            SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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
	CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
        COUNT(`Transaction ID`) AS total_successful_orders,
        SUM(`Gross Amount`) AS total_gross_sales,
        SUM(`Discount`) AS total_discount,
        SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
        SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
        `Commission Rate` AS commission_rate,
        CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_1,

        SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
        SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
        SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,

	SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
            ELSE 0.00
        END
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END,2) AS total_amount_paid_out
    FROM 
        `transaction_summary_view` tsv
    JOIN
        `store` ON `Store ID` = store.`store_id`
    WHERE 
        `Store ID` = "', store_id, '"
        AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
    GROUP BY 
        `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_store_decoupled_report` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO settlement_report_history_decoupled
        (decoupled_report_id, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_number, total_successful_orders, total_gross_sales, total_discount, total_net_sales, leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id,
            `Store ID` AS store_id,
            store.legal_entity_name AS store_business_name,
	    `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
            
	    COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_pretrial,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Promo Fulfillment Type` = ''Decoupled''
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
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,

            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_net_sales,

            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''PRE-TRIAL'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_pretrial,

            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                ELSE 0
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_billable,

            ROUND(SUM(CASE
                WHEN `Commission Type` = ''Vat Exc'' THEN (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate` * 1.12
                ELSE (CASE
                    WHEN `Bill Status` = ''BILLABLE'' THEN (`Gross Amount` - `Discount`)
                    ELSE 0
                END) * `Commission Rate`
            END),2) AS total_commission_fees
        FROM 
            `transaction_summary_view` tsv
        JOIN
            `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	    AND `Promo Fulfillment Type` = ''Decoupled''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `merchant_coupled_report` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO settlement_report_history_coupled 
        (coupled_report_id, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_number, total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, leadgen_commission_rate_base, commission_rate, total_commission_fees_1, paymaya_pg_fee, paymaya_credit_card_pg_fee, maya_pg_fee, maya_checkout_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, cwt_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees,total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
	    `Merchant ID` AS merchant_id, 
            merchant.legal_entity_name AS merchant_business_name, 
            `Merchant Name` AS merchant_brand_name,
            merchant.business_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
            SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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
	    AND `Promo Fulfillment Type` = ''Coupled''
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
	CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
        COUNT(`Transaction ID`) AS total_successful_orders,
        SUM(`Gross Amount`) AS total_gross_sales,
        SUM(`Discount`) AS total_discount,
        SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
        SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
        `Commission Rate` AS commission_rate,
        CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_1,

        SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
        SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
        SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,

	SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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
	AND `Promo Fulfillment Type` = ''Coupled''
    GROUP BY 
        `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `store_coupled_report` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO settlement_report_history_coupled 
        (coupled_report_id, store_id, store_business_name, store_brand_name, address, settlement_period_start, settlement_period_end, total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, leadgen_commission_rate_base, commission_rate, total_commission_fees_1, paymaya_pg_fee, paymaya_credit_card_pg_fee, maya_pg_fee, maya_checkout_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, cwt_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees,total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
	    `Store ID` AS store_id, 
            store.legal_entity_name AS store_business_name, 
            `Store Name` AS store_brand_name,
            store.store_address AS business_address,
            "', start_date, '" AS settlement_period_start,
            "', end_date, '" AS settlement_period_end,
	    CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
            SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
            `Commission Rate` AS commission_rate,
            CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_1,
            SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
            SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
            SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
            SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
            SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,
            SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	    CASE
                WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
                ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
            END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
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
	    AND `Promo Fulfillment Type` = ''Coupled''
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
	CONCAT(DATE_FORMAT("', end_date, '", "%Y%m"), ''-'', LEFT("', v_uuid, '", 6)) AS settlement_number,
        COUNT(`Transaction ID`) AS total_successful_orders,
        SUM(`Gross Amount`) AS total_gross_sales,
        SUM(`Discount`) AS total_discount,
        SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_1,
        SUM(`Gross Amount` - `Discount`) AS leadgen_commission_rate_base,
        `Commission Rate` AS commission_rate,
        CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_1,

        SUM(CASE WHEN `Payment` = ''paymaya'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_pg_fee,
        SUM(CASE WHEN `Payment` = ''paymaya_credit_card'' THEN `PG Fee Amount` ELSE 0 END) AS paymaya_credit_card_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya'' THEN `PG Fee Amount` ELSE 0 END) AS maya_pg_fee,
        SUM(CASE WHEN `Payment` = ''maya_checkout'' THEN `PG Fee Amount` ELSE 0 END) AS maya_checkout_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash_miniapp'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_miniapp_pg_fee,
        SUM(CASE WHEN `Payment` = ''gcash'' THEN `PG Fee Amount` ELSE 0 END) AS gcash_pg_fee,
        SUM(`PG Fee Amount`) AS total_payment_gateway_fees_1,

	SUM(`Gross Amount` - `Discount`) AS total_outstanding_amount_2,
	CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END AS total_commission_fees_2,
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
	ROUND(SUM(`Gross Amount` - `Discount`)
	- CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12),2)
            ELSE ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100)),2)
        END
	- SUM(`PG Fee Amount`)
	- 10.00
	- ROUND((SUM(`Gross Amount`)-SUM(`PG Fee Amount`)) / 2 * 0.01,2)
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM((`Gross Amount` - `Discount`) * (`Commission Rate` / 100) * 1.12) / 1.12 * 0.02, 2)
            ELSE 0.00
        END
	+ CASE
            WHEN `Commission Type` = ''VAT Exc'' THEN ROUND(SUM(`PG Fee Amount`) / 1.12 * 0.02, 2)
            ELSE 0.00
        END,2) AS total_amount_paid_out
    FROM 
        `transaction_summary_view` tsv
    JOIN
        `store` ON `Store ID` = store.`store_id`
    WHERE 
        `Store ID` = "', store_id, '"
        AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	AND `Promo Fulfillment Type` = ''Coupled''
    GROUP BY 
        `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
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
('08785777-2795-11ef-a232-0a002700000d', NULL, 'user', '08783957-2795-11ef-a232-0a002700000d', 'Add', 'User record added\nemail_address: sample@email.com\npassword: sample123\nname: Sample User\ntype: Admin\nstatus: ', '2024-06-11 01:50:51', '2024-06-11 01:50:51'),
('3caf218d-1f21-11ef-a08a-48e7dad87c24', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Add', 'User record added\nemail_address: admin@bookymail.ph\npassword: admin123\nname: Admin\ntype: Admin\nstatus: Active', '2024-05-31 07:41:48', '2024-05-31 07:41:48'),
('446c137a-1f21-11ef-a08a-48e7dad87c24', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Update', 'User record updated\npassword: admin123 -> admin123booky', '2024-05-31 07:42:01', '2024-05-31 07:42:01'),
('bcd83021-2927-11ef-8b55-0a002700000d', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Update', 'User record updated\nname: Admin -> Booky Admin', '2024-06-13 01:53:32', '2024-06-13 01:53:32');

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
  `paymaya_credit_card` decimal(4,2) NOT NULL,
  `paymaya` decimal(4,2) NOT NULL,
  `gcash` decimal(4,2) NOT NULL,
  `gcash_miniapp` decimal(4,2) NOT NULL,
  `maya_checkout` decimal(4,2) NOT NULL,
  `maya` decimal(4,2) NOT NULL,
  `lead_gen_commission` decimal(4,2) NOT NULL,
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
CREATE TRIGGER `generate_fee_id` BEFORE INSERT ON `fee` FOR EACH ROW BEGIN
    SET NEW.fee_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_fee_log` AFTER UPDATE ON `fee` FOR EACH ROW BEGIN
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
  `merchant_partnership_type` enum('Primary','Secondary') NOT NULL,
  `merchant_type` enum('Grab & Go','Casual Dining') NOT NULL,
  `legal_entity_name` varchar(255) DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `email_address` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant`
--

INSERT INTO `merchant` (`merchant_id`, `merchant_name`, `merchant_partnership_type`, `merchant_type`, `legal_entity_name`, `business_address`, `email_address`, `created_at`, `updated_at`) VALUES
('3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B00KY Demo Merchant', 'Primary', 'Grab & Go', 'Merchant Legal Name', 'Somewhere St.', 'merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph', '2024-05-28 07:16:32', '2024-06-04 02:49:53');

--
-- Triggers `merchant`
--
DELIMITER $$
CREATE TRIGGER `generate_merchant_id` BEFORE INSERT ON `merchant` FOR EACH ROW BEGIN
    SET NEW.merchant_id = UUID();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `promo`
--

CREATE TABLE `promo` (
  `promo_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `promo_amount` int(11) NOT NULL DEFAULT 0,
  `promo_fulfillment_type` enum('Coupled','Decoupled') NOT NULL,
  `promo_group` enum('Booky','Gcash','Unionbank','Gcash/Booky','UB/Booky') NOT NULL,
  `promo_type` enum('% off','FREE','bundle','bogo','price off') NOT NULL,
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

INSERT INTO `promo` (`promo_id`, `merchant_id`, `promo_code`, `promo_amount`, `promo_fulfillment_type`, `promo_group`, `promo_type`, `promo_details`, `remarks`, `bill_status`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
('4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B00KYDEMO', 100, 'Coupled', 'Gcash', 'bundle', 'Booky sample promo', '', 'BILLABLE', '2024-04-01', '2024-07-31', '2024-06-04 02:34:19', '2024-06-04 02:34:49');

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
CREATE TRIGGER `update_promo_log` AFTER UPDATE ON `promo` FOR EACH ROW BEGIN
  IF OLD.bill_status != NEW.bill_status THEN
    INSERT INTO promo_history (promo_history_id, promo_id, old_bill_status, new_bill_status)
    VALUES (UUID(), NEW.promo_id, OLD.bill_status, NEW.bill_status);
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
  `promo_id` varchar(36) NOT NULL,
  `old_bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `new_bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `changed_at` date NOT NULL DEFAULT current_timestamp(),
  `changed_by` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promo_history`
--

INSERT INTO `promo_history` (`promo_history_id`, `promo_id`, `old_bill_status`, `new_bill_status`, `changed_at`, `changed_by`) VALUES
('1bee95d1-294c-11ef-8b55-0a002700000d', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'PRE-TRIAL', 'BILLABLE', '2024-06-13', NULL);

--
-- Triggers `promo_history`
--
DELIMITER $$
CREATE TRIGGER `generate_promo_history_id` BEFORE INSERT ON `promo_history` FOR EACH ROW BEGIN
    SET NEW.promo_history_id = UUID(); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `settlement_report_history_coupled`
--

CREATE TABLE `settlement_report_history_coupled` (
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
  `settlement_number` varchar(20) NOT NULL,
  `total_successful_orders` int(11) NOT NULL,
  `total_gross_sales` decimal(10,2) NOT NULL,
  `total_discount` decimal(10,2) NOT NULL,
  `total_outstanding_amount_1` decimal(10,2) NOT NULL,
  `leadgen_commission_rate_base` decimal(10,2) NOT NULL,
  `commission_rate` varchar(10) NOT NULL,
  `total_commission_fees_1` decimal(10,2) NOT NULL,
  `paymaya_pg_fee` decimal(10,2) NOT NULL,
  `paymaya_credit_card_pg_fee` decimal(10,2) NOT NULL,
  `maya_pg_fee` decimal(10,2) NOT NULL,
  `maya_checkout_pg_fee` decimal(10,2) NOT NULL,
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
-- Triggers `settlement_report_history_coupled`
--
DELIMITER $$
CREATE TRIGGER `generate_coupled_report_id` BEFORE INSERT ON `settlement_report_history_coupled` FOR EACH ROW BEGIN
    SET NEW.coupled_report_id = UUID();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `settlement_report_history_decoupled`
--

CREATE TABLE `settlement_report_history_decoupled` (
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
  `settlement_number` varchar(20) NOT NULL,
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
-- Dumping data for table `settlement_report_history_decoupled`
--

INSERT INTO `settlement_report_history_decoupled` (`decoupled_report_id`, `generated_by`, `merchant_id`, `merchant_business_name`, `merchant_brand_name`, `store_id`, `store_business_name`, `store_brand_name`, `business_address`, `settlement_period_start`, `settlement_period_end`, `settlement_number`, `total_successful_orders`, `total_gross_sales`, `total_discount`, `total_net_sales`, `leadgen_commission_rate_base_pretrial`, `commission_rate_pretrial`, `total_pretrial`, `leadgen_commission_rate_base_billable`, `commission_rate_billable`, `total_billable`, `total_commission_fees`, `created_at`, `updated_at`) VALUES
('22df3d60-295c-11ef-8b55-0a002700000d', NULL, NULL, NULL, NULL, '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'Demo Legal Name', 'B00KY Demo Store', 'Anywhere St.', '2024-05-01', '2024-05-31', '202405-22dc5e', 2, '22244.00', '5784.00', '16460.00', '890.00', '10.00%', '9968.00', '15570.00', '10.00%', '174384.00', '174384.00', '2024-06-13 08:08:37', '2024-06-13 08:08:37');

--
-- Triggers `settlement_report_history_decoupled`
--
DELIMITER $$
CREATE TRIGGER `generate_decoupled_report_id` BEFORE INSERT ON `settlement_report_history_decoupled` FOR EACH ROW BEGIN
    SET NEW.decoupled_report_id = UUID();
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
    SET NEW.store_id = UUID();
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
  `promo_id` varchar(36) NOT NULL,
  `customer_id` varchar(14) NOT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `transaction_date` datetime NOT NULL,
  `gross_amount` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) NOT NULL,
  `amount_discounted` decimal(10,2) NOT NULL,
  `payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya') NOT NULL,
  `bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`transaction_id`, `store_id`, `promo_id`, `customer_id`, `customer_name`, `transaction_date`, `gross_amount`, `discount`, `amount_discounted`, `payment`, `bill_status`, `created_at`, `updated_at`) VALUES
('1bc0f5fe-224b-11ef-b01f-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '\"639121234345\"', 'Maria Demo', '2024-05-15 16:17:58', '20760.00', '5190.00', '15570.00', 'paymaya_credit_card', 'BILLABLE', '2024-06-01 08:17:58', '2024-06-05 03:42:49'),
('8d1552bf-1cc3-11ef-8abb-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '\"639123456789\"', 'Juan Person', '2024-05-28 09:25:43', '1484.00', '594.00', '890.00', 'gcash', 'PRE-TRIAL', '2024-05-28 07:26:08', '2024-05-28 07:26:08'),
('e881c2e7-224a-11ef-b01f-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '\"639987654321\"', 'Anna Human', '2024-06-06 10:16:20', '15570.00', '3114.00', '12456.00', 'paymaya_credit_card', 'PRE-TRIAL', '2024-06-04 08:17:39', '2024-06-04 08:17:39');

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
,`Promo ID` varchar(8)
,`Promo Code` varchar(100)
,`Promo Fulfillment Type` enum('Coupled','Decoupled')
,`Promo Group` enum('Booky','Gcash','Unionbank','Gcash/Booky','UB/Booky')
,`Promo Type` enum('% off','FREE','bundle','bogo','price off')
,`Gross Amount` decimal(10,2)
,`Discount` decimal(10,2)
,`Amount Discounted` decimal(10,2)
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
('3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'admin@bookymail.ph', 'admin123booky', 'Booky Admin', 'Admin', 'Active', '2024-05-31 07:41:48', '2024-05-31 07:41:48');

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

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_summary_view`  AS SELECT substr(`t`.`transaction_id`,1,8) AS `Transaction ID`, `t`.`transaction_date` AS `Transaction Date`, `m`.`merchant_id` AS `Merchant ID`, `m`.`merchant_name` AS `Merchant Name`, `s`.`store_id` AS `Store ID`, `s`.`store_name` AS `Store Name`, `t`.`customer_id` AS `Customer ID`, `t`.`customer_name` AS `Customer Name`, substr(`p`.`promo_id`,1,8) AS `Promo ID`, `p`.`promo_code` AS `Promo Code`, `p`.`promo_fulfillment_type` AS `Promo Fulfillment Type`, `p`.`promo_group` AS `Promo Group`, `p`.`promo_type` AS `Promo Type`, `t`.`gross_amount` AS `Gross Amount`, `t`.`discount` AS `Discount`, `t`.`amount_discounted` AS `Amount Discounted`, `t`.`payment` AS `Payment`, `t`.`bill_status` AS `Bill Status`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) AS `Commission Type`, coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`lead_gen_commission`,'%')) AS `Commission Rate`, round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100,2) AS `Commission Amount`, CASE WHEN coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` AND `fh`.`column_name` = 'commission_type' AND `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Exc' THEN round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100 * 1.12,2) WHEN coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` AND `fh`.`column_name` = 'commission_type' AND `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Inc' THEN round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100,2) END AS `Total Billing`, CASE WHEN `t`.`payment` = 'paymaya_credit_card' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya_credit_card' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`paymaya_credit_card`,'%'))) WHEN `t`.`payment` = 'gcash' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`gcash`,'%'))) WHEN `t`.`payment` = 'gcash_miniapp' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash_miniapp' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`gcash_miniapp`,'%'))) WHEN `t`.`payment` = 'paymaya' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`paymaya`,'%'))) WHEN `t`.`payment` = 'maya_checkout' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya_checkout' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`maya_checkout`,'%'))) WHEN `t`.`payment` = 'maya' THEN (select coalesce((select concat(`fh`.`old_value`,'%') from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),concat(`f`.`maya`,'%'))) END AS `PG Fee Rate`, CASE WHEN `t`.`payment` = 'paymaya_credit_card' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya_credit_card' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya_credit_card`)) / 100,2) WHEN `t`.`payment` = 'gcash' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash`)) / 100,2) WHEN `t`.`payment` = 'gcash_miniapp' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash_miniapp' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash_miniapp`)) / 100,2) WHEN `t`.`payment` = 'paymaya' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya`)) / 100,2) WHEN `t`.`payment` = 'maya_checkout' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya_checkout' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya_checkout`)) / 100,2) WHEN `t`.`payment` = 'maya' THEN round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya`)) / 100,2) END AS `PG Fee Amount`, round(`t`.`amount_discounted` - case when coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Exc' then round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100 * 1.12,2) when coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) = 'Vat Inc' then round(`t`.`amount_discounted` * coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) / 100,2) end - case when `t`.`payment` = 'paymaya_credit_card' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya_credit_card' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya_credit_card`)) / 100,2) when `t`.`payment` = 'gcash' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash`)) / 100,2) when `t`.`payment` = 'gcash_miniapp' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'gcash_miniapp' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`gcash_miniapp`)) / 100,2) when `t`.`payment` = 'paymaya' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'paymaya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`paymaya`)) / 100,2) when `t`.`payment` = 'maya_checkout' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya_checkout' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya_checkout`)) / 100,2) when `t`.`payment` = 'maya' then round(`t`.`amount_discounted` * (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'maya' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`maya`)) / 100,2) end,2) AS `Amount to be Disbursed` FROM ((((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `promo` `p` on(`p`.`merchant_id` = `m`.`merchant_id`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`)) ORDER BY `t`.`transaction_date` ASC  ;

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
  ADD UNIQUE KEY `pg_fee_rate_ibfk_1` (`merchant_id`) USING BTREE;

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
  ADD PRIMARY KEY (`promo_id`),
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `promo_history`
--
ALTER TABLE `promo_history`
  ADD PRIMARY KEY (`promo_history_id`),
  ADD KEY `promo_history_ibfk_1` (`promo_id`);

--
-- Indexes for table `settlement_report_history_coupled`
--
ALTER TABLE `settlement_report_history_coupled`
  ADD PRIMARY KEY (`coupled_report_id`),
  ADD KEY `settlement_report_history_ibfk1` (`merchant_id`),
  ADD KEY `settlement_report_history_ibfk2` (`generated_by`),
  ADD KEY `settlement_report_history_ibfk3` (`store_id`);

--
-- Indexes for table `settlement_report_history_decoupled`
--
ALTER TABLE `settlement_report_history_decoupled`
  ADD PRIMARY KEY (`decoupled_report_id`);

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
  ADD KEY `offer_id` (`promo_id`);

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
  ADD CONSTRAINT `promo_history_ibfk_1` FOREIGN KEY (`promo_id`) REFERENCES `promo` (`promo_id`);

--
-- Constraints for table `settlement_report_history_coupled`
--
ALTER TABLE `settlement_report_history_coupled`
  ADD CONSTRAINT `settlement_report_history_ibfk1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`),
  ADD CONSTRAINT `settlement_report_history_ibfk2` FOREIGN KEY (`generated_by`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `settlement_report_history_ibfk3` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`);

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
  ADD CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`promo_id`) REFERENCES `promo` (`promo_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
