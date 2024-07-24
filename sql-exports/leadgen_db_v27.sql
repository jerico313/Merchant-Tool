-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 20, 2024 at 10:57 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

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
CREATE DEFINER=`root`@`localhost` PROCEDURE `coupled_merchant_all` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_coupled 
        (coupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees_1, 
         card_payment_pg_fee, paymaya_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, 
         total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, 
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
            ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `coupled_merchant_billable` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_coupled 
        (coupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees_1, 
         card_payment_pg_fee, paymaya_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, 
         total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, 
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `coupled_merchant_pretrial` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_coupled 
        (coupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount_1, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees_1, 
         card_payment_pg_fee, paymaya_pg_fee, gcash_miniapp_pg_fee, gcash_pg_fee, total_payment_gateway_fees_1, 
         total_outstanding_amount_2, total_commission_fees_2, total_payment_gateway_fees_2, bank_fees, 
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
            ''PRE-TRIAL'' AS bill_status, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS coupled_report_id, 
            ''PRE-TRIAL'' AS bill_status, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `coupled_store_all` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

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
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out)
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `coupled_store_billable` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

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
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
            ''BILLABLE'' AS bill_status, 
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS coupled_report_id, 
            ''BILLABLE'' AS bill_status, 
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `coupled_store_pretrial` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

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
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out)
        SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS coupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount_1,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees_1,

            SUM(CASE WHEN `Mode of Payment` IN (''paymaya_credit_card'', ''maya'', ''maya_checkout'') THEN `PG Fee Amount` ELSE 0 END) AS card_payment,
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
	        10.00 AS bank_fees,
    	    ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2) AS wtax_from_gross_sales,
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * `CWT Rate`, 2) AS cwt_from_transaction_fees,
            ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2) AS cwt_from_pg_fees,
            
            ROUND(
                SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - 10.00
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * `CWT Rate`, 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * `CWT Rate`, 2),
            2) AS total_amount_paid_out
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Coupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `decoupled_merchant_all` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `decoupled_merchant_billable` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `decoupled_merchant_pretrial` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
            ''PRE-TRIAL'' AS bill_status, 
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
            ''PRE-TRIAL'' AS bill_status, 
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `decoupled_store_all` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, 
         settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `decoupled_store_billable` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, 
         settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
            ''BILLABLE'' AS bill_status, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
            ''BILLABLE'' AS bill_status, 
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
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `decoupled_store_pretrial` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, 
         settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT 
            "', v_uuid, '" AS decoupled_report_id, 
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
            COUNT(`Transaction ID`) AS total_successful_orders,
            SUM(`Gross Amount`) AS total_gross_sales,
            SUM(`Discount`) AS total_discount,
            SUM(`Cart Amount`) AS total_outstanding_amount,
            
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_pretrial,

           SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Comm Rate Base`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_billable,
            `Commission Rate` AS commission_rate_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
	        AND `Voucher Type` = ''Decoupled''
	        AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_select FROM @sql_select;
    EXECUTE stmt_select;
    DEALLOCATE PREPARE stmt_select;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_merchant_all` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Merchant ID`');

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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
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
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_merchant_billable` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS gcash_report_id,
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	        "', v_uuid, '" AS gcash_report_id, 
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
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
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_merchant_pretrial` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS gcash_report_id,
            ''PRE-TRIAL'' AS bill_status, 
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Merchant ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	        "', v_uuid, '" AS gcash_report_id, 
            ''PRE-TRIAL'' AS bill_status, 
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
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
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_store_all` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS gcash_report_id,
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	        "', v_uuid, '" AS gcash_report_id, 
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
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
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 

            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_store_billable` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
        SELECT 
            "', v_uuid, '" AS gcash_report_id,
            ''BILLABLE'' AS bill_status, 
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Store ID`');

    PREPARE stmt_insert FROM @sql_insert;
    EXECUTE stmt_insert;
    DEALLOCATE PREPARE stmt_insert;

    SET @sql_select = CONCAT('SELECT
	        "', v_uuid, '" AS gcash_report_id, 
            ''BILLABLE'' AS bill_status, 
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
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
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_store_pretrial` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
        (gcash_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate,commission_amount, vat_amount, total_commission_fees)
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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Store ID`');

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

            SUM(`Cart Amount`) AS total_amount,
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
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
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
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Promo Code`');

    PREPARE stmt_insert1 FROM @sql_insert1;
    EXECUTE stmt_insert1;
    DEALLOCATE PREPARE stmt_insert1;

    SET @sql_select1 = CONCAT('SELECT 
            "', v_uuid, '"  AS gcash_report_id,
            p.promo_code as item,
            COUNT(`Transaction ID`) AS quantity_redeemed,
	        SUM(`Cart Amount`) AS net_amount
        FROM 
            `transaction_summary_view`
        JOIN
            `promo` p ON `Promo Code` = p.promo_code
        WHERE 
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Promo Group` = ''Gcash''
            AND `Bill Status` = ''PRE-TRIAL''
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
('00e19be3-4676-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '778a5700-678b-489f-9be2-22a96bab523c', 'Update', 'Merchant record updated\nmerchant_id: 778a5700-678b-489f-9be2-22a96bab523c', '2024-07-20 08:56:50', '2024-07-20 08:56:50'),
('01d65bdb-4412-11ef-951c-48e7dad87c24', NULL, 'merchant', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Update', 'Merchant record updated\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda', '2024-07-17 07:56:00', '2024-07-17 07:56:00'),
('031c1b47-3826-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '031c090d-3826-11ef-9d23-0a002700000d', 'Add', 'User record added\nemail_address: rominna@booky.ph\npassword: $2y$10$Q49RiBWN5YY4ifaslsE8he7XHED6Jr0vyQ7s5Izij4bg57oneXY9W\nname: Rominna Angeline R. Raymundo\ntype: User\nstatus: Inactive', '2024-07-02 03:48:58', '2024-07-02 04:03:11'),
('03cbdfcc-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', 'dd50d96b', 'Update', 'Transaction record updated\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e -> 6cb2f0fe-253d-49c9-b52b-db44354138c8', '2024-07-17 11:30:48', '2024-07-17 11:30:48'),
('0743f147-31f8-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '07430231-31f8-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-07430231\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:04:41', '2024-07-02 04:03:42'),
('07461dba-31f8-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '07430231-31f8-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 07430231-31f8-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 15570.00\namount: 31140.00', '2024-06-24 07:04:41', '2024-07-02 04:03:42'),
('07462182-31f8-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '07430231-31f8-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 07430231-31f8-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00\namount: 1600.00', '2024-06-24 07:04:41', '2024-07-02 04:03:42'),
('08785777-2795-11ef-a232-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '08783957-2795-11ef-a232-0a002700000d', 'Add', 'User record added\nemail_address: sample@email.com\npassword: sample123\nname: Sample User\ntype: Admin\nstatus: ', '2024-06-11 01:50:51', '2024-07-02 04:03:42'),
('09d8e1a3-342e-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '09d8d971-342e-11ef-b7ae-0a002700000d', 'Add', 'User record added\nemail_address: cookie@booky.ph\npassword: $2y$10$QPrvim.Z8xAZjI2TOLASWeXwuaxjn4dzob7tLlB90Vp9PUpa8XyE2\nname: Cookie\ntype: User\nstatus: Inactive', '2024-06-27 02:36:21', '2024-07-02 04:03:42'),
('0d693fae-31f4-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Promo record updated\nvoucher_type: Coupled -> Decoupled', '2024-06-24 06:36:13', '2024-07-02 04:03:42'),
('0ff4bf89-3826-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '031c090d-3826-11ef-9d23-0a002700000d', 'Update', 'User record updated\nuser_id: 031c090d-3826-11ef-9d23-0a002700000d\nstatus: Inactive -> Active', '2024-07-02 03:49:19', '2024-07-02 04:03:42'),
('1298e7ee-4407-11ef-951c-48e7dad87c24', NULL, 'report_history_coupled', '12983c64-4407-11ef-951c-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL and BILLABLE\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nmerchant_business_name: Taipefoods Inc.\nmerchant_brand_name: Shi Lin\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 2100 ID Building, Don Chino Roces extension, Brgy. Magallanes, Makati City\nsettlement_period_start: 2024-07-01\nsettlement_period_end: 2024-07-31\nsettlement_number: SR#LG2024-07-17-12983c64\ntotal_successful_orders: 2\ntotal_gross_sales: 4702.00\ntotal_discount: 500.00\ntotal_outstanding_amount_1: 4202.00\nleadgen_commission_rate_base_pretrial: 0.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 0.00\nleadgen_commission_rate_base_billable: 6202.00\ncommission_rate_billable: 10.00%\ntotal_billable: 620.20\ntotal_commission_fees_1: 620.20\ncard_payment_pg_fee: 92.44\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 0.00\ntotal_payment_gateway_fees_1: 92.44\ntotal_outstanding_amount_2: 4202.00\ntotal_commission_fees_2: 620.20\ntotal_payment_gateway_fees_2: 92.44\nbank_fees: 10.00\nwtax_from_gross_sales: 20.55\ncwt_from_transaction_fees: 0.00\ncwt_from_pg_fees: 0.00\ntotal_amount_paid_out: 3458.81', '2024-07-17 06:37:43', '2024-07-17 06:37:43'),
('1299fbd4-342e-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '09d8d971-342e-11ef-b7ae-0a002700000d', 'Update', 'User record updated\ntype: User -> Admin', '2024-06-27 02:36:35', '2024-07-02 04:03:42'),
('12b91ac6-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', '6ea596b0', 'Update', 'Transaction record updated\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e -> b2ce0524-02b0-4bfc-b05d-8b637ff52ff5', '2024-07-17 11:31:13', '2024-07-17 11:31:13'),
('145e24df-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '09d8d971-342e-11ef-b7ae-0a002700000d', 'Update', 'User record updated\nuser_id: 09d8d971-342e-11ef-b7ae-0a002700000d\nname: Cookie -> Admin', '2024-07-04 01:17:04', '2024-07-04 02:30:15'),
('157b709f-31f4-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '157b5bac-31f4-11ef-a30f-0a002700000d', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-157ab0f9\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 179.20\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-24 06:36:27', '2024-07-02 04:03:42'),
('16af0c8d-342b-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'store', '8946759b-1cc2-11ef-8abb-48e7dad87c24', 'Update', 'Store record updated\nstore_name: B00KY Demo Store -> B00KY Demo Store Edited', '2024-06-27 02:15:14', '2024-07-02 04:03:42'),
('16bbee82-4648-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:28:10', '2024-07-20 03:28:10'),
('1706b837-342e-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '09d8d971-342e-11ef-b7ae-0a002700000d', 'Update', 'User record updated\nstatus: Inactive -> Active', '2024-06-27 02:36:43', '2024-07-02 04:03:42'),
('177fb933-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '09d8d971-342e-11ef-b7ae-0a002700000d', 'Update', 'User record updated\nuser_id: 09d8d971-342e-11ef-b7ae-0a002700000d\nemail_address: cookie@booky.ph -> admin@booky.ph', '2024-07-04 01:17:09', '2024-07-04 02:30:15'),
('1a9d5902-4412-11ef-951c-48e7dad87c24', NULL, 'merchant', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Update', 'Merchant record updated\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda', '2024-07-17 07:56:41', '2024-07-17 07:56:41'),
('1c32e936-37c4-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\npromo_type:  -> Bundle', '2024-07-01 16:08:09', '2024-07-02 04:03:42'),
('1c3ad6cf-31f2-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '1c3abfde-31f2-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-1c39d6\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 47.24\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26548.66', '2024-06-24 06:22:19', '2024-07-02 04:03:42'),
('1c4bf5c0-4440-11ef-951c-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nemail_address: shilin@booky.ph -> cookie@booky.ph', '2024-07-17 13:26:00', '2024-07-17 13:26:00'),
('1c9a876c-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', 'eb9964e2', 'Update', 'Transaction record updated\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e -> b745e964-eba8-4372-a940-167be6c2c227', '2024-07-17 11:31:30', '2024-07-17 11:31:30'),
('1ca269d0-32be-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '1ca1a39f-32be-11ef-b166-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_date: June 25, 2024\nsettlement_number: SR#LG2024-06-25-1ca1\nsettlement_period: May 1-31, 2024\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 99.68\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-25 06:42:37', '2024-07-02 04:03:42'),
('1e5309ed-4412-11ef-951c-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-17 07:56:48', '2024-07-17 07:56:48'),
('1f013e33-45dc-11ef-9af2-48e7dad87c24', NULL, 'report_history_decoupled', '1f00bc47-45dc-11ef-9af2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL and BILLABLE\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-19-1f00bc47\ntotal_successful_orders: 8\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 8000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 896.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-19 14:35:18', '2024-07-19 14:35:18'),
('1f2869f9-4648-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:28:24', '2024-07-20 03:28:24'),
('1f819850-4672-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '9f8d0113-5719-4994-bb9d-03fea73f8644', 'Update', 'Merchant record updated\nmerchant_id: 9f8d0113-5719-4994-bb9d-03fea73f8644', '2024-07-20 08:29:04', '2024-07-20 08:29:04'),
('209a3b1c-32ba-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '20994229-32ba-11ef-b166-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: SR#LG-20240625-20994\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 28916.00\nleadgen_commission_rate_base: 28916.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2466.32\ncard_payment_pg_fee: 342.54\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 452.66\ntotal_payment_gateway_fees_1: 795.20\ntotal_outstanding_amount_2: 28916.00\ntotal_commission_fees_2: 2466.32\ntotal_payment_gateway_fees_2: 795.20\nbank_fees: 10.00\ncwt_from_gross_sales: 185.09\ncwt_from_transaction_fees: 45.38\ncwt_from_pg_fees: 14.20\ntotal_amount_paid_out: 25517.63', '2024-06-25 06:14:06', '2024-07-02 04:03:42'),
('23ebaeda-4406-11ef-951c-48e7dad87c24', NULL, 'promo', 'dee3716e-37c3-11ef-bccf-0a002700000d', 'Update', 'Promo record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nvoucher_type: Decoupled -> Coupled', '2024-07-17 06:31:03', '2024-07-17 06:31:03'),
('250f9151-4672-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '62f0f17f-4039-4993-8e64-84b03910c005', 'Update', 'Merchant record updated\nmerchant_id: 62f0f17f-4039-4993-8e64-84b03910c005', '2024-07-20 08:29:13', '2024-07-20 08:29:13'),
('26b16070-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', 'eb9964e2', 'Update', 'Transaction record updated\nstore_id: b745e964-eba8-4372-a940-167be6c2c227 -> 67789d26-7c0f-4147-9f40-149aca3c0f9a', '2024-07-17 11:31:47', '2024-07-17 11:31:47'),
('2715561d-31f4-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '27153ce8-31f4-11ef-a30f-0a002700000d', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-2713761c\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 179.20\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-24 06:36:56', '2024-07-02 04:03:42'),
('28e05e02-3826-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Update', 'Merchant record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24', '2024-07-02 03:50:01', '2024-07-02 04:03:42'),
('2bb64213-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-2bb4d85b\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-24 07:27:11', '2024-07-02 04:03:42'),
('2bb7b24b-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 2bb4d85b-31fb-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:27:11', '2024-07-02 04:03:42'),
('2bb80317-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '2bb4d85b-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 2bb4d85b-31fb-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:27:11', '2024-07-02 04:03:42'),
('2c57bc60-3826-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-02 03:50:07', '2024-07-02 04:03:42'),
('2ec2656b-31f3-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '2ec24d91-31f3-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-2ec0997c\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 48.58\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26547.32', '2024-06-24 06:30:00', '2024-07-02 04:03:42'),
('30668ad9-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '031c090d-3826-11ef-9d23-0a002700000d', 'Update', 'User record updated\nuser_id: 031c090d-3826-11ef-9d23-0a002700000d', '2024-07-04 01:17:51', '2024-07-04 02:30:15'),
('350d7051-32be-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '350cbf0b-32be-11ef-b166-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_date: June 25, 2024\nsettlement_number: SR#LG2024-06-25-350c\nsettlement_period: May 1-31, 2024\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 99.68\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-25 06:43:18', '2024-07-02 04:03:42'),
('3522a86b-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '09d8d971-342e-11ef-b7ae-0a002700000d', 'Update', 'User record updated\nuser_id: 09d8d971-342e-11ef-b7ae-0a002700000d', '2024-07-04 01:17:59', '2024-07-04 02:30:15'),
('376f5b7d-464a-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nmerchant_name:  -> Shi Lin\nlegal_entity_name: Taipeifoods Inc. -> Primary\nemail_address: cookie@booky.ph -> -', '2024-07-20 03:43:24', '2024-07-20 03:43:24'),
('37f5bcaa-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', 'b1a44bae-3825-11ef-9d23-0a002700000d', 'Update', 'User record updated\nuser_id: b1a44bae-3825-11ef-9d23-0a002700000d', '2024-07-04 01:18:04', '2024-07-04 02:30:15'),
('3a63e3b8-3811-11ef-814b-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'transaction', '6c851d41-37c4-11ef-bccf-0a002700000d', 'Update', 'Transaction record updated\ntransaction_date: 2024-07-01 18:09:29 -> 2024-07-30 18:09:29', '2024-07-02 01:20:11', '2024-07-02 04:03:42'),
('3b50e3e9-3453-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Fee record updated\npaymaya_credit_card: 1.50 -> 1.75\nmaya_checkout: 1.50 -> 1.75\nmaya: 1.50 -> 1.75', '2024-06-27 07:02:35', '2024-07-02 04:03:42'),
('3b617e0f-345e-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Update', 'Merchant record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nemail_address: merchantdemo1@booky.ph, merchantdemo2@booky.ph, merchantdemo3@booky.ph, merchantdemo4@booky.ph -> merchantdemo1@booky.ph,merchantdemo2@booky.ph,merchantdemo3@booky.ph,merchantdemo4@booky.ph', '2024-06-27 08:21:19', '2024-07-02 04:03:42'),
('3c942c76-31f3-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '3c941093-31f3-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-3c92ce35\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 47.24\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26548.66', '2024-06-24 06:30:23', '2024-07-02 04:03:42'),
('3caf218d-1f21-11ef-a08a-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Add', 'User record added\nemail_address: admin@bookymail.ph\npassword: admin123\nname: Admin\ntype: Admin\nstatus: Active', '2024-05-31 07:41:48', '2024-07-02 04:03:42'),
('3f405210-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', 'd67668ed', 'Update', 'Transaction record updated\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e -> d61b2260-42e0-4281-be7a-bc3fb3244bd1', '2024-07-17 11:32:28', '2024-07-17 11:32:28'),
('41a37f61-2d28-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_fulfillment_type: Coupled -> Decoupled', '2024-06-18 04:07:19', '2024-07-02 04:03:42'),
('421419bb-31f7-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '4212c6cf-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_date: \nsettlement_number: 202405-4212c6\nsettlement_period: \ntotal_amount: N/A\ncommission_rate: N/A\nvat_amount: N/A\ntotal_commission_fees: N/A', '2024-06-24 06:59:10', '2024-07-02 04:03:42'),
('446c137a-1f21-11ef-a08a-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Update', 'User record updated\npassword: admin123 -> admin123booky', '2024-05-31 07:42:01', '2024-07-02 04:03:42'),
('44c1bfb4-2d51-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '44c1a44d-2d51-11ef-a4d2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-44c085\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_net_sales: 18060.00\nleadgen_commission_rate_base_pretrial: 2490.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 278.88\nleadgen_commission_rate_base_billable: 15570.00\ncommission_rate_billable: 10.00%\ntotal_billable: 1743.84\ntotal_commission_fees: 1743.84', '2024-06-18 09:00:54', '2024-07-02 04:03:42'),
('479898a1-442c-11ef-951c-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nlegal_entity_name: Taipefoods Inc. -> Taipeifoods Inc.', '2024-07-17 11:04:04', '2024-07-17 11:04:04'),
('47cd51c1-45e3-11ef-9af2-48e7dad87c24', NULL, 'report_history_decoupled', '47cce1e0-45e3-11ef-9af2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL and BILLABLE\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-19-47cce1e0\ntotal_successful_orders: 9\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 9000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 1008.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-19 15:26:33', '2024-07-19 15:26:33'),
('487dcf91-4415-11ef-951c-48e7dad87c24', NULL, 'transaction', 'd67668ed', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639064050757\"\ntransaction_date: 2024-04-26 15:38:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:19:27', '2024-07-17 08:19:27'),
('487dd2d2-4415-11ef-951c-48e7dad87c24', NULL, 'transaction', '0f1b2d4d', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639225334747\"\ntransaction_date: 2024-04-26 19:10:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:19:27', '2024-07-17 08:19:27'),
('487dd5fe-4415-11ef-951c-48e7dad87c24', NULL, 'transaction', 'abf475bf', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639776077101\"\ntransaction_date: 2024-04-27 20:33:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:19:27', '2024-07-17 08:19:27'),
('487dd871-4415-11ef-951c-48e7dad87c24', NULL, 'transaction', 'd0a90e98', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639776077101\"\ntransaction_date: 2024-04-28 13:34:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:19:27', '2024-07-17 08:19:27'),
('48a028c4-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', '0f1b2d4d', 'Update', 'Transaction record updated\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e -> 6cb2f0fe-253d-49c9-b52b-db44354138c8', '2024-07-17 11:32:43', '2024-07-17 11:32:43'),
('49e94ed4-3429-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Fee record updated\ngcash_miniapp: 3.00 -> 2.75', '2024-06-27 02:02:21', '2024-07-02 04:03:42'),
('4a1f1033-37c4-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'transaction', '4a1ea5f4-37c4-11ef-bccf-0a002700000d', 'Add', 'Transaction record added\nstore_id: b8af69b1-37c3-11ef-bccf-0a002700000d\npromo_code: SHILIN500\ncustomer_id: \"639987654321\"\ntransaction_date: 2024-06-30 00:08:18\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-01 16:09:26', '2024-07-02 04:03:42'),
('4bee6418-4671-11ef-b60e-48e7dad87c24', NULL, 'merchant', '62f0f17f-4039-4993-8e64-84b03910c005', 'Add', 'Merchant record added\nmerchant_name: Auntie Anne\'s\nmerchant_partnership_type: N/A\nlegal_entity_name: Pretiolas Philippines Inc.\nbusiness_address: NO OSC\nemail_address: ', '2024-07-20 08:23:09', '2024-07-20 08:23:09'),
('4d693dd7-442c-11ef-951c-48e7dad87c24', NULL, 'store', 'b8af69b1-37c3-11ef-bccf-0a002700000d', 'Update', 'Store record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nlegal_entity_name: Taipefoods Inc. -> Taipeifoods Inc.', '2024-07-17 11:04:13', '2024-07-17 11:04:13'),
('4df4a29b-32ba-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '4df3a4af-32ba-11ef-b166-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: SR#LG2024-06-25-4df3\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 28916.00\nleadgen_commission_rate_base: 28916.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2466.32\ncard_payment_pg_fee: 342.54\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 452.66\ntotal_payment_gateway_fees_1: 795.20\ntotal_outstanding_amount_2: 28916.00\ntotal_commission_fees_2: 2466.32\ntotal_payment_gateway_fees_2: 795.20\nbank_fees: 10.00\ncwt_from_gross_sales: 185.09\ncwt_from_transaction_fees: 45.38\ncwt_from_pg_fees: 14.20\ntotal_amount_paid_out: 25517.63', '2024-06-25 06:15:22', '2024-07-02 04:03:42'),
('5146d920-4413-11ef-951c-48e7dad87c24', NULL, 'promo', '5146a532-4413-11ef-951c-48e7dad87c24', 'Add', 'Promo record added\n\npromo_code: UBANGELS10\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\npromo_amount: 1000\nvoucher_type: Decoupled\npromo_category: Casual Dining\npromo_group: Unionbank\npromo_type: Percent discount\npromo_details: Get 10% off with a minimum spend of ₱1,000\nremarks: free, min spend 1000\nbill_status: PRE-TRIAL\nstart_date: 2024-04-19\nend_date: 2024-07-19', '2024-07-17 08:05:23', '2024-07-17 08:05:23'),
('523ca345-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', 'abf475bf', 'Update', 'Transaction record updated\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e -> b745e964-eba8-4372-a940-167be6c2c227', '2024-07-17 11:33:00', '2024-07-17 11:33:00'),
('538256ba-31fa-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '53818781-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-53818781\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:21:08', '2024-07-02 04:03:42'),
('5384285f-31fa-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '53818781-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 53818781-31fa-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:21:08', '2024-07-02 04:03:42'),
('5384315e-31fa-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '53818781-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 53818781-31fa-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:21:08', '2024-07-02 04:03:42'),
('556063bf-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', '0f1b2d4d', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:26:58', '2024-07-17 08:26:58'),
('55b66a4e-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Update', 'Merchant record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24', '2024-07-02 03:44:07', '2024-07-02 04:03:42'),
('55ed2f49-4430-11ef-951c-48e7dad87c24', NULL, 'transaction', 'd0a90e98', 'Update', 'Transaction record updated\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e -> b745e964-eba8-4372-a940-167be6c2c227', '2024-07-17 11:33:06', '2024-07-17 11:33:06'),
('583b3364-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Update', 'Merchant record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24', '2024-07-02 03:44:11', '2024-07-02 04:03:42'),
('596e58bb-37c5-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee', '596e3a87-37c5-11ef-bccf-0a002700000d', 'Add', 'Fee record added\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\npaymaya_credit_card: 2.50\npaymaya: 2.00\ngcash: 2.00\ngcash_miniapp: 2.00\nmaya_checkout: 2.50\nmaya: 2.50\nlead_gen_commission: 10.00\ncommission_type: VAT Inc', '2024-07-01 16:17:02', '2024-07-02 04:03:42'),
('599dd82f-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '599d1847-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-599d18', '2024-06-18 08:54:19', '2024-07-02 04:03:42'),
('59a03527-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '599d1847-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: 599d1847-2d50-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:54:19', '2024-07-02 04:03:42'),
('5a09fee3-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-02 03:44:14', '2024-07-02 04:03:42'),
('5c5495f0-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-02 03:44:18', '2024-07-02 04:03:42'),
('5dae44bc-45e3-11ef-9af2-48e7dad87c24', NULL, 'report_history_decoupled', '5dade388-45e3-11ef-9af2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-19-5dade388\ntotal_successful_orders: 9\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 9000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 1008.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-19 15:27:10', '2024-07-19 15:27:10'),
('6019edd2-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', '0f1b2d4d', 'Update', 'Transaction record updated', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('6019f4f3-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', '6ea596b0', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('6019f8d6-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', '8461f2b3', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('6019fc81-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', '902dc726', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('601a0024-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', 'abf475bf', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('601a039e-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', 'd0a90e98', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('601a06fd-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', 'd67668ed', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('601a0a5e-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', 'dd50d96b', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('601a0dd5-4416-11ef-951c-48e7dad87c24', NULL, 'transaction', 'eb9964e2', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 08:27:16', '2024-07-17 08:27:16'),
('61af7a9b-31ef-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '61af61a6-31ef-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-61ae33\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 06:02:47', '2024-07-02 04:03:42'),
('63f30570-31f7-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '63f1b962-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_date: Jun 24, 2024\nsettlement_number: 202405-63f1b962\nsettlement_period: May 1 - May 31, 2024\ntotal_amount: 1600.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:00:07', '2024-07-02 04:03:42'),
('63f531cb-31f7-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '63f1b962-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 63f1b962-31f7-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00\namount: 1600.00', '2024-06-24 07:00:07', '2024-07-02 04:03:42'),
('6850aa26-37c5-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Fee record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\npaymaya_credit_card: 1.75 -> 1.80\nmaya_checkout: 1.75 -> 1.80\nmaya: 1.75 -> 1.80', '2024-07-01 16:17:26', '2024-07-02 04:03:42'),
('6990aac1-31ee-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '69909518-31ee-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-698f4d\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_outstanding_amount_1: 1600.00\nleadgen_commission_rate_base: 1600.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 179.20\ncard_payment_pg_fee: 0.00\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 44.00\ntotal_outstanding_amount_2: 1600.00\ntotal_commission_fees_2: 179.20\ntotal_payment_gateway_fees_2: 44.00\nbank_fees: 10.00\ncwt_from_gross_sales: 8.78\ncwt_from_transaction_fees: 3.20\ncwt_from_pg_fees: 0.79\ntotal_amount_paid_out: 1362.01', '2024-06-24 05:55:51', '2024-07-02 04:03:42'),
('6a368a72-4400-11ef-951c-48e7dad87c24', NULL, 'store', 'b8af69b1-37c3-11ef-bccf-0a002700000d', 'Update', 'Store record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nlegal_entity_name: Taipefoods Inc. -> Taipeifoods Inc.', '2024-07-17 05:50:04', '2024-07-17 05:50:04'),
('6b1bc7c0-45db-11ef-9af2-48e7dad87c24', NULL, 'transaction', 'd0a90e98', 'Update', 'Transaction record updated\ntransaction_date: 2024-04-28 13:34:00 -> 2024-04-30 13:34:00', '2024-07-19 14:30:17', '2024-07-19 14:30:17'),
('6b5975be-2d27-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'settlement_report_history_coupled', '6b5956c6-2d27-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-6b581a\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 802.98\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 802.98\nbank_fees: 10.00\ncwt_from_gross_sales: 107.21\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 14.34\ntotal_amount_paid_out: 13743.55', '2024-06-18 04:01:19', '2024-07-02 04:03:42'),
('6b8a3a3c-2ed7-11ef-bafd-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '6b8a15bf-2ed7-11ef-bafd-48e7dad87c24', 'Add', 'User record added\nemail_address: cookie@booky.ph\npassword: $2y$10$xXT7USa7PPtpQJm4g1xq8O..A2cKtV4/YbW.aJiKx0R2fobDZUa3m\nname: Cookie\ntype: User\nstatus: Inactive', '2024-06-20 07:33:42', '2024-07-02 04:03:42'),
('6c85810b-37c4-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'transaction', '6c851d41-37c4-11ef-bccf-0a002700000d', 'Add', 'Transaction record added\nstore_id: b8af69b1-37c3-11ef-bccf-0a002700000d\npromo_code: SHILIN500\ncustomer_id: \"639574848321\"\ntransaction_date: 2024-07-01 18:09:29\ngross_amount: 4702.00\ndiscount: 500.00\namount_discounted: 4202.00\npayment: maya_checkout\nbill_status: BILLABLE', '2024-07-01 16:10:24', '2024-07-02 04:03:42'),
('6d8cb4f9-4400-11ef-951c-48e7dad87c24', NULL, 'store', 'b8af69b1-37c3-11ef-bccf-0a002700000d', 'Update', 'Store record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nlegal_entity_name: Taipeifoods Inc. -> Taipefoods Inc.', '2024-07-17 05:50:10', '2024-07-17 05:50:10'),
('6e0aca8a-2d3e-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nfixed_discount: 0 -> 1\nfree_item: 0 -> 1', '2024-06-18 06:46:02', '2024-07-02 04:03:42'),
('6ec3575e-4671-11ef-b60e-48e7dad87c24', NULL, 'merchant', '62f0f17f-4039-4993-8e64-84b03910c005', 'Update', 'Merchant record updated\nmerchant_id: 62f0f17f-4039-4993-8e64-84b03910c005', '2024-07-20 08:24:07', '2024-07-20 08:24:07'),
('70dfeb33-45e0-11ef-9af2-48e7dad87c24', NULL, 'report_history_decoupled', '70df88b7-45e0-11ef-9af2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-19-70df88b7\ntotal_successful_orders: 8\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 8000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 896.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-19 15:06:14', '2024-07-19 15:06:14'),
('733485b4-32c4-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '7332e83f-32c4-11ef-b166-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: June 25, 2024\nsettlement_number: SR#LG2024-06-25-7332\nsettlement_period: May 1-Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-25 07:27:59', '2024-07-02 04:03:42'),
('73365dea-32c4-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '7332e83f-32c4-11ef-b166-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: 7332e83f-32c4-11ef-b166-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-25 07:27:59', '2024-07-02 04:03:42'),
('733663ef-32c4-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '7332e83f-32c4-11ef-b166-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: 7332e83f-32c4-11ef-b166-48e7dad87c24\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-25 07:27:59', '2024-07-02 04:03:42'),
('74b3c994-2d22-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_fulfillment_type: Decoupled -> Coupled', '2024-06-18 03:25:48', '2024-07-02 04:03:42');
INSERT INTO `activity_history` (`activity_id`, `user_id`, `table_name`, `table_id`, `activity_type`, `description`, `created_at`, `updated_at`) VALUES
('770a5f73-2d22-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'settlement_report_history_coupled', '770a0718-2d22-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-7708ad\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 2466.32\nleadgen_commission_rate_base: 2466.32\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2268.80\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 1121.04\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 1145.52\ntotal_outstanding_amount_2: 2466.32\ntotal_commission_fees_2: 2268.80\ntotal_payment_gateway_fees_2: 1145.52\nbank_fees: 10.00\ncwt_from_gross_sales: 12.33\ncwt_from_transaction_fees: 4.31\ncwt_from_pg_fees: 20.46\ntotal_amount_paid_out: -945.56', '2024-06-18 03:25:52', '2024-07-02 04:03:42'),
('7a235de6-465e-11ef-b60e-48e7dad87c24', NULL, 'report_history_coupled', '7a22c391-465e-11ef-b60e-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL and BILLABLE\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nmerchant_business_name: Taipeifoods Inc.\nmerchant_brand_name: Shi Lin\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: N/A\nsettlement_period_start: 2024-07-01\nsettlement_period_end: 2024-07-30\nsettlement_number: SR#LG2024-07-20-7a22c391\ntotal_successful_orders: 2\ntotal_gross_sales: 4702.00\ntotal_discount: 500.00\ntotal_outstanding_amount_1: 4202.00\nleadgen_commission_rate_base_pretrial: 4202.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 420.20\nleadgen_commission_rate_base_billable: 2000.00\ncommission_rate_billable: 10.00%\ntotal_billable: 200.00\ntotal_commission_fees_1: 200.00\ncard_payment_pg_fee: 92.44\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 0.00\ntotal_payment_gateway_fees_1: 92.44\ntotal_outstanding_amount_2: 4202.00\ntotal_commission_fees_2: 200.00\ntotal_payment_gateway_fees_2: 92.44\nbank_fees: 10.00\nwtax_from_gross_sales: 20.55\ncwt_from_transaction_fees: 0.00\ncwt_from_pg_fees: 0.00\ntotal_amount_paid_out: 3879.01', '2024-07-20 06:08:26', '2024-07-20 06:08:26'),
('7a4cca3d-31f7-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '7a45e8c3-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-7a45e8c3\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:00:44', '2024-07-02 04:03:42'),
('7a54379f-464d-11ef-b60e-48e7dad87c24', NULL, 'report_history_coupled', '7a52e8e9-464d-11ef-b60e-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nbill_status: BILLABLE\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nmerchant_business_name: Taipeifoods Inc.\nmerchant_brand_name: Shi Lin\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: N/A\nsettlement_period_start: 2024-07-01\nsettlement_period_end: 2024-07-30\nsettlement_number: SR#LG2024-07-20-7a52e8e9\ntotal_successful_orders: 1\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount_1: 0.00\nleadgen_commission_rate_base_pretrial: 0.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 0.00\nleadgen_commission_rate_base_billable: 2000.00\ncommission_rate_billable: 10.00%\ntotal_billable: 200.00\ntotal_commission_fees_1: 200.00\ncard_payment_pg_fee: 0.00\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 0.00\ntotal_payment_gateway_fees_1: 0.00\ntotal_outstanding_amount_2: 0.00\ntotal_commission_fees_2: 200.00\ntotal_payment_gateway_fees_2: 0.00\nbank_fees: 10.00\nwtax_from_gross_sales: 0.00\ncwt_from_transaction_fees: 0.00\ncwt_from_pg_fees: 0.00\ntotal_amount_paid_out: -210.00', '2024-07-20 04:06:45', '2024-07-20 04:06:45'),
('7ab1ac90-31f7-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '7a45e8c3-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 7a45e8c3-31f7-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 3\nnet_amount: 15570.00\namount: 46710.00', '2024-06-24 07:00:45', '2024-07-02 04:03:42'),
('7d40dedf-4406-11ef-951c-48e7dad87c24', NULL, 'fee', '596e3a87-37c5-11ef-bccf-0a002700000d', 'Update', 'Fee record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nis_cwt_rate_computed: 1 -> 0', '2024-07-17 06:33:33', '2024-07-17 06:33:33'),
('7d413c84-4406-11ef-951c-48e7dad87c24', NULL, 'fee_history', '7d41172a-4406-11ef-951c-48e7dad87c24', 'Add', 'Fee history record added\nfee_id: 596e3a87-37c5-11ef-bccf-0a002700000d\ncolumn_name: is_cwt_rate_computed\nold_value: 1\nnew_value: 0\nchanged_at: 2024-07-17 14:33:33\nchanged_by: N/A', '2024-07-17 06:33:33', '2024-07-17 06:33:33'),
('7d48141a-2d22-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'settlement_report_history_coupled', '7d47f605-2d22-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-7d46e9\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 28916.00\nleadgen_commission_rate_base: 28916.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2541.06\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 1121.04\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 1145.52\ntotal_outstanding_amount_2: 28916.00\ntotal_commission_fees_2: 2541.06\ntotal_payment_gateway_fees_2: 1145.52\nbank_fees: 10.00\ncwt_from_gross_sales: 183.34\ncwt_from_transaction_fees: 45.38\ncwt_from_pg_fees: 20.46\ntotal_amount_paid_out: 25101.92', '2024-06-18 03:26:02', '2024-07-02 04:03:42'),
('7f9a3266-32b8-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '7f97eba5-32b8-11ef-b166-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-7f97eba5\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 28916.00\nleadgen_commission_rate_base: 28916.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2466.32\ncard_payment_pg_fee: 342.54\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 452.66\ntotal_payment_gateway_fees_1: 795.20\ntotal_outstanding_amount_2: 28916.00\ntotal_commission_fees_2: 2466.32\ntotal_payment_gateway_fees_2: 795.20\nbank_fees: 10.00\ncwt_from_gross_sales: 185.09\ncwt_from_transaction_fees: 45.38\ncwt_from_pg_fees: 14.20\ntotal_amount_paid_out: 25517.63', '2024-06-25 06:02:26', '2024-07-02 04:03:42'),
('81d181ba-31f2-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '81d155ed-31f2-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-81d08642\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 47.24\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26548.66', '2024-06-24 06:25:10', '2024-07-02 04:03:42'),
('828b4bc6-2eb6-11ef-abc9-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_amount: 100.00 -> 120.00', '2024-06-20 03:38:08', '2024-07-02 04:03:42'),
('83cdf8af-344f-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '83cbfc16-344f-11ef-b7ae-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store Edited\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: June 27, 2024\nsettlement_number: SR#LG2024-06-27-83cb\nsettlement_period: May 1-Jun 30, 2024\ntotal_amount: 17170.00\ncommission_rate: 10.00%\nvat_amount: 206.04\ntotal_commission_fees: 1923.04', '2024-06-27 06:35:58', '2024-07-02 04:03:42'),
('83d0ed89-344f-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '83cbfc16-344f-11ef-b7ae-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 83cbfc16-344f-11ef-b7ae-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 1\nnet_amount: 15570.00', '2024-06-27 06:35:59', '2024-07-02 04:03:42'),
('83d0f74a-344f-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '83cbfc16-344f-11ef-b7ae-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 83cbfc16-344f-11ef-b7ae-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-27 06:35:59', '2024-07-02 04:03:42'),
('85051eec-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Promo record added\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\npromo_code: GCA5H\npromo_amount: 200.00\npromo_fulfillment_type: Coupled\npromo_group: Gcash\nbogo: 0\nbundle: 0\nfixed_discount: 1\nfree_item: 0\npercent_discount: 0\nx_for_y: 0\npromo_details: gcash promo details\nremarks: N/A\nbill_status: PRE-TRIAL\nstart_date: 2024-03-01\nend_date: 2024-07-31', '2024-06-18 08:55:32', '2024-07-02 04:03:42'),
('8753c07f-3897-11ef-b4b1-0a002700000d', NULL, 'fee', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Fee record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\npaymaya_credit_card: 1.80 -> 2.00\nmaya_checkout: 1.80 -> 2.00\nmaya: 1.80 -> 2.00', '2024-07-04 02:24:42', '2024-07-04 02:32:47'),
('8753deeb-3897-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee_history', '8753d0e1-3897-11ef-b4b1-0a002700000d', 'Add', 'Fee history record added\nfee_id: 02f361d3-1cc3-11ef-8abb-48e7dad87c24\ncolumn_name: paymaya_credit_card\nold_value: 1.80\nnew_value: 2.00\nchanged_at: 2024-07-04 10:24:42\nchanged_by: N/A', '2024-07-04 02:24:42', '2024-07-04 02:30:15'),
('875405cf-3897-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee_history', '8754011f-3897-11ef-b4b1-0a002700000d', 'Add', 'Fee history record added\nfee_id: 02f361d3-1cc3-11ef-8abb-48e7dad87c24\ncolumn_name: maya_checkout\nold_value: 1.80\nnew_value: 2.00\nchanged_at: 2024-07-04 10:24:42\nchanged_by: N/A', '2024-07-04 02:24:42', '2024-07-04 02:30:15'),
('8754bef9-3897-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee_history', '87540b77-3897-11ef-b4b1-0a002700000d', 'Add', 'Fee history record added\nfee_id: 02f361d3-1cc3-11ef-8abb-48e7dad87c24\ncolumn_name: maya\nold_value: 1.80\nnew_value: 2.00\nchanged_at: 2024-07-04 10:24:42\nchanged_by: N/A', '2024-07-04 02:24:42', '2024-07-04 02:30:15'),
('8ad3fc5d-45db-11ef-9af2-48e7dad87c24', NULL, 'report_history_decoupled', '8ad37df2-45db-11ef-9af2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-19-8ad37df2\ntotal_successful_orders: 8\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 8000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 896.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-19 14:31:10', '2024-07-19 14:31:10'),
('8b553d09-2d26-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'settlement_report_history_coupled', '8b552490-2d26-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-8b540d\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 802.98\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 802.98\nbank_fees: 10.00\ncwt_from_gross_sales: 107.21\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 14.34\ntotal_amount_paid_out: 13743.55', '2024-06-18 03:55:04', '2024-07-02 04:03:42'),
('8bd01309-37c5-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'transaction', '4a1ea5f4-37c4-11ef-bccf-0a002700000d', 'Update', 'Transaction record updated\ntransaction_date: 2024-06-30 00:08:18 -> 2024-07-01 00:08:18', '2024-07-01 16:18:26', '2024-07-02 04:03:42'),
('8d332030-342a-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Update', 'Merchant record updated\nemail_address: merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph, merchantdemo@booky.ph -> merchantdemo1@booky.ph, merchantdemo2@booky.ph, merchantdemo3@booky.ph, merchantdemo4@booky.ph', '2024-06-27 02:11:23', '2024-07-02 04:03:42'),
('8d941ede-4648-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:31:29', '2024-07-20 03:31:29'),
('8fad4d33-31ee-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nvoucher_type: Decoupled -> Coupled', '2024-06-24 05:56:55', '2024-07-02 04:03:42'),
('90709c30-32be-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '906fc330-32be-11ef-b166-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: June 25, 2024\nsettlement_number: SR#LG2024-06-25-906f\nsettlement_period: May 1-Jun 30, 2024\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 99.68\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-25 06:45:52', '2024-07-02 04:03:42'),
('9217dccf-440f-11ef-951c-48e7dad87c24', NULL, 'merchant', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Add', 'Merchant record added\nmerchant_name: Angel\'s Pizza\nmerchant_partnership_type: Primary\nlegal_entity_name: Figaro Coffee Systems, Inc.\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nemail_address: cookie@booky.ph', '2024-07-17 07:38:33', '2024-07-17 07:38:33'),
('93612d48-4645-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:10:11', '2024-07-20 03:10:11'),
('946594a3-4648-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:31:41', '2024-07-20 03:31:41'),
('967ceea5-342b-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '967b54d6-342b-11ef-b7ae-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store Edited\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: June 27, 2024\nsettlement_number: SR#LG2024-06-27-967b\nsettlement_period: May 1-Jun 30, 2024\ntotal_amount: 17170.00\ncommission_rate: 10.00%\nvat_amount: 206.04\ntotal_commission_fees: 1923.04', '2024-06-27 02:18:48', '2024-07-02 04:03:42'),
('967ef1e3-342b-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '967b54d6-342b-11ef-b7ae-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 967b54d6-342b-11ef-b7ae-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 1\nnet_amount: 15570.00', '2024-06-27 02:18:48', '2024-07-02 04:03:42'),
('967ef67c-342b-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '967b54d6-342b-11ef-b7ae-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: 967b54d6-342b-11ef-b7ae-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-27 02:18:48', '2024-07-02 04:03:42'),
('97e42414-2ebe-11ef-abc9-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_type: 0 -> Free item, Fixed discount', '2024-06-20 04:35:59', '2024-07-02 04:03:42'),
('99f84246-31ee-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', '99f82de1-31ee-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-99f763\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 68.48\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 05:57:12', '2024-07-02 04:03:42'),
('9c4191b4-41b8-11ef-b2d4-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-14 08:11:02', '2024-07-14 08:11:02'),
('9cf95766-32c3-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', '9cf7b744-32c3-11ef-b166-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: June 25, 2024\nsettlement_number: SR#LG2024-06-25-9cf7\nsettlement_period: May 1-Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-25 07:22:00', '2024-07-02 04:03:42'),
('9cfca144-32c3-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '9cf7b744-32c3-11ef-b166-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: 9cf7b744-32c3-11ef-b166-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-25 07:22:00', '2024-07-02 04:03:42'),
('9cfcf5e9-32c3-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', '9cf7b744-32c3-11ef-b166-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: 9cf7b744-32c3-11ef-b166-48e7dad87c24\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-25 07:22:00', '2024-07-02 04:03:42'),
('9f398ac5-4675-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '62f0f17f-4039-4993-8e64-84b03910c005', 'Update', 'Merchant record updated\nmerchant_id: 62f0f17f-4039-4993-8e64-84b03910c005', '2024-07-20 08:54:06', '2024-07-20 08:54:06'),
('a2f1259c-2d24-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'settlement_report_history_coupled', 'a2f101ad-2d24-11ef-a7c7-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-a2f018\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 24.48\ntotal_payment_gateway_fees_1: 802.98\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 802.98\nbank_fees: 10.00\ncwt_from_gross_sales: 107.21\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 14.34\ntotal_amount_paid_out: 13743.55', '2024-06-18 03:41:24', '2024-07-02 04:03:42'),
('a3d1d89c-2ebe-11ef-abc9-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Promo record updated\npromo_type: 0 -> BOGO', '2024-06-20 04:36:19', '2024-07-02 04:03:42'),
('a4e2661f-4675-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '62f0f17f-4039-4993-8e64-84b03910c005', 'Update', 'Merchant record updated\nmerchant_id: 62f0f17f-4039-4993-8e64-84b03910c005', '2024-07-20 08:54:16', '2024-07-20 08:54:16'),
('a667cc4e-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'transaction', 'a6673ec0-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Transaction record added\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\npromo_id: 8504f541-2d50-11ef-a4d2-48e7dad87c24\ncustomer_id: \"638572947601\"\ntransaction_date: 2024-06-18 10:55:41\ngross_amount: 1800.00\ndiscount: 200.00\namount_discounted: 1600.00\npayment: gcash\nbill_status: PRE-TRIAL', '2024-06-18 08:56:28', '2024-07-02 04:03:42'),
('a79d34ab-4671-11ef-b60e-48e7dad87c24', NULL, 'merchant', '9f8d0113-5719-4994-bb9d-03fea73f8644', 'Add', 'Merchant record added\nmerchant_name: Banh Mi Kitchen\nmerchant_partnership_type: N/A\nlegal_entity_name: \nbusiness_address: \nemail_address: ', '2024-07-20 08:25:42', '2024-07-20 08:25:42'),
('a89441e6-37c3-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Add', 'Merchant record added\nmerchant_name: Shi Lin\nmerchant_partnership_type: Primary\nlegal_entity_name: Taipefoods Inc.\nbusiness_address: 2100 ID Building, Don Chino Roces extension, Brgy. Magallanes, Makati City\nemail_address: shilin@booky.ph', '2024-07-01 16:04:55', '2024-07-02 04:03:42'),
('a8e5cb96-3427-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Fee record updated\npaymaya_credit_card: 2.75 -> 1.50\nmaya_checkout: 2.75 -> 1.50\nmaya: 2.50 -> 1.50', '2024-06-27 01:50:41', '2024-07-02 04:03:42'),
('abc213d1-31f7-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'abc1668b-31f7-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-abc1668b\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:02:08', '2024-07-02 04:03:42'),
('acea9513-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', 'acea8342-388e-11ef-b4b1-0a002700000d', 'Add', 'User record added\nemail_address: cookie@booky.ph\npassword: $2y$10$dRffZ66tPS8hHDmkIWssSOOlk21L1/H3g1lOz6J8uxldv.BM.5rci\nname: Cookie\ntype: User\nstatus: Inactive', '2024-07-04 01:21:20', '2024-07-04 02:30:15'),
('ad01a25b-45e8-11ef-9af2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_decoupled', 'ad011b0d-45e8-11ef-9af2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-20-ad011b0d\ntotal_successful_orders: 9\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 9000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 1008.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-19 16:05:11', '2024-07-19 16:05:11'),
('af210407-2ebe-11ef-abc9-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nremarks:  -> not billable \"forever\"', '2024-06-20 04:36:38', '2024-07-02 04:03:42'),
('b0ad6776-2eb8-11ef-abc9-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'b0acea51-2eb8-11ef-abc9-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-b0ab5e\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\npaymaya_pg_fee: 0.00\npaymaya_credit_card_pg_fee: 778.50\nmaya_pg_fee: 0.00\nmaya_checkout_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 68.48\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-20 03:53:44', '2024-07-02 04:03:42'),
('b115b12c-31f2-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'b1159c73-31f2-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: 202406-b11440c7\ntotal_successful_orders: 4\ntotal_gross_sales: 39614.00\ntotal_discount: 9098.00\ntotal_outstanding_amount_1: 30516.00\nleadgen_commission_rate_base: 30516.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2645.52\ncard_payment_pg_fee: 1121.04\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 1189.52\ntotal_outstanding_amount_2: 30516.00\ntotal_commission_fees_2: 2645.52\ntotal_payment_gateway_fees_2: 1189.52\nbank_fees: 10.00\ncwt_from_gross_sales: 192.12\ncwt_from_transaction_fees: 48.58\ncwt_from_pg_fees: 21.24\ntotal_amount_paid_out: 26547.32', '2024-06-24 06:26:29', '2024-07-02 04:03:42'),
('b123f325-31fa-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'b1230378-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-b1230378\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 1.20\ntotal_commission_fees: 11.20', '2024-06-24 07:23:45', '2024-07-02 04:03:42'),
('b125cb0e-31fa-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'b1230378-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: b1230378-31fa-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:23:45', '2024-07-02 04:03:42'),
('b125cdfb-31fa-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'b1230378-31fa-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: b1230378-31fa-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:23:45', '2024-07-02 04:03:42'),
('b1a4623e-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', 'b1a44bae-3825-11ef-9d23-0a002700000d', 'Add', 'User record added\nemail_address: ben@booky.ph\npassword: $2y$10$nNJgZho7u3EoVduIQvNqquhWT/mrR2j6foaVuAHx9QpOcrdxG14ce\nname: Ben Wintle\ntype: User\nstatus: Inactive', '2024-07-02 03:46:41', '2024-07-02 04:03:42'),
('b1d0de0f-344e-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Promo record updated\npromo_group: Gcash -> Gcash/Booky', '2024-06-27 06:30:06', '2024-07-02 04:03:42'),
('b42ef62c-2d4e-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'b42ddf53-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-b42ddf', '2024-06-18 08:42:32', '2024-07-02 04:03:42'),
('b430d7f0-2d4e-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'b42ddf53-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: b42ddf53-2d4e-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:42:32', '2024-07-02 04:03:42'),
('b586a999-4648-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:32:36', '2024-07-20 03:32:36'),
('b7843bb5-31f1-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'b7842860-31f1-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-b78352\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 06:19:30', '2024-07-02 04:03:42'),
('b8afb20a-37c3-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'store', 'b8af69b1-37c3-11ef-bccf-0a002700000d', 'Add', 'Store record added\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nstore_name: Shi Lin Branch\nlegal_entity_name: Taipefoods Inc.\nstore_address: 2100 ID Building, Don Chino Roces extension, Brgy. Magallanes, Makati City', '2024-07-01 16:05:22', '2024-07-02 04:03:42'),
('b8b5fa7f-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', 'b1a44bae-3825-11ef-9d23-0a002700000d', 'Update', 'User record updated\nuser_id: b1a44bae-3825-11ef-9d23-0a002700000d\nstatus: Inactive -> Active', '2024-07-02 03:46:53', '2024-07-02 04:03:42'),
('ba47a6a7-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', 'acea8342-388e-11ef-b4b1-0a002700000d', 'Update', 'User record updated\nuser_id: acea8342-388e-11ef-b4b1-0a002700000d', '2024-07-04 01:21:42', '2024-07-04 02:30:15'),
('bb92c21d-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'bb91e9e6-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-bb91e9', '2024-06-18 08:57:03', '2024-07-02 04:03:42'),
('bc030dcd-2eb6-11ef-abc9-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-06-20 03:39:44', '2024-07-02 04:03:42'),
('bc031474-2eb6-11ef-abc9-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo_history', 'bc03116e-2eb6-11ef-abc9-48e7dad87c24', 'Add', 'Promo history record added\npromo_code: B00KYDEMO\nold_bill_status: BILLABLE\nnew_bill_status: PRE-TRIAL\nchanged_at: 2024-06-20\nchanged_by: N/A', '2024-06-20 03:39:44', '2024-07-02 04:03:42'),
('bc3b8e66-36f7-11ef-8f86-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'bc2fa1b6-36f7-11ef-8f86-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-30\nsettlement_number: SR#LG2024-06-30-bc2f\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\ncard_payment_pg_fee: 0.00\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 428.18\ntotal_payment_gateway_fees_1: 428.18\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 428.18\nbank_fees: 10.00\ncwt_from_gross_sales: 109.08\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 7.65\ntotal_amount_paid_out: 14109.79', '2024-06-30 15:45:11', '2024-07-02 04:03:42'),
('bcd83021-2927-11ef-8b55-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Update', 'User record updated\nname: Admin -> Booky Admin', '2024-06-13 01:53:32', '2024-07-02 04:03:42'),
('bd900b46-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'bd8ef28d-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-bd8ef28d\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-24 07:31:15', '2024-07-02 04:03:42'),
('bd91f740-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'bd8ef28d-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: bd8ef28d-31fb-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:31:15', '2024-07-02 04:03:42'),
('bd91fb26-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'bd8ef28d-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: bd8ef28d-31fb-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:31:15', '2024-07-02 04:03:42'),
('bd9a1e69-2d1e-11ef-a7c7-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'Update', 'Promo record updated\npromo_fulfillment_type: Coupled -> Decoupled', '2024-06-18 02:59:12', '2024-07-02 04:03:42'),
('be923d26-4674-11ef-b60e-48e7dad87c24', NULL, 'merchant', '778a5700-678b-489f-9be2-22a96bab523c', 'Add', 'Merchant record added\nmerchant_name: Mesa\nmerchant_partnership_type: N/A\nlegal_entity_name: N/A\nbusiness_address: N/A\nemail_address: N/A', '2024-07-20 08:47:49', '2024-07-20 08:47:49'),
('bf5284d1-344e-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', '8504f541-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Promo record updated\npromo_group: Gcash/Booky -> Unionbank', '2024-06-27 06:30:29', '2024-07-02 04:03:42'),
('c063b1d4-32b9-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'c0625900-32b9-11ef-b166-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: SR#LG-20240625-c0625\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 28916.00\nleadgen_commission_rate_base: 28916.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2466.32\ncard_payment_pg_fee: 342.54\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 452.66\ntotal_payment_gateway_fees_1: 795.20\ntotal_outstanding_amount_2: 28916.00\ntotal_commission_fees_2: 2466.32\ntotal_payment_gateway_fees_2: 795.20\nbank_fees: 10.00\ncwt_from_gross_sales: 185.09\ncwt_from_transaction_fees: 45.38\ncwt_from_pg_fees: 14.20\ntotal_amount_paid_out: 25517.63', '2024-06-25 06:11:24', '2024-07-02 04:03:42'),
('c22e7044-37bf-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'transaction', 'a6673ec0-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Transaction record updated\ntransaction_date: 2024-09-18 10:55:41 -> 2024-06-13 10:55:41', '2024-07-01 15:37:00', '2024-07-02 04:03:42'),
('c4f035e9-4648-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:33:02', '2024-07-20 03:33:02'),
('c65a58c8-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Update', 'Merchant record updated\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24', '2024-07-02 03:47:16', '2024-07-02 04:03:42'),
('c7178641-4645-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:11:37', '2024-07-20 03:11:37'),
('ca53c232-3825-11ef-9d23-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-02 03:47:23', '2024-07-02 04:03:42'),
('cf1512db-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'cf141684-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-cf1416', '2024-06-18 08:57:36', '2024-07-02 04:03:42'),
('cf17118f-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'cf141684-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: cf141684-2d50-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 4\nvoucher_value: 100.00\namount: 400.00', '2024-06-18 08:57:36', '2024-07-02 04:03:42'),
('cfe2b7ef-37c5-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'fee', '596e3a87-37c5-11ef-bccf-0a002700000d', 'Update', 'Fee record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\npaymaya_credit_card: 2.50 -> 2.20\nmaya_checkout: 2.50 -> 2.20\nmaya: 2.50 -> 2.20', '2024-07-01 16:20:20', '2024-07-02 04:03:42'),
('d1b78cf0-4407-11ef-951c-48e7dad87c24', NULL, 'promo', 'd1b7698b-4407-11ef-951c-48e7dad87c24', 'Add', 'Promo record added\n\npromo_code: PRESHILIN\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\npromo_amount: 200\nvoucher_type: Coupled\npromo_category: Casual Dining\npromo_group: Unionbank\npromo_type: Free item\npromo_details: Pre-trial shi lin promo\nremarks: N/A\nbill_status: PRE-TRIAL\nstart_date: 2024-04-01\nend_date: 2024-09-30', '2024-07-17 06:43:04', '2024-07-17 06:43:04'),
('d450e7af-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'd4502354-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: Jun 24, 2024\nsettlement_number: 202406-d4502354\nsettlement_period: May 1 - Jun 30, 2024\ntotal_amount: 18060.00\ncommission_rate: 10.00%\nvat_amount: 216.72\ntotal_commission_fees: 2022.72', '2024-06-24 07:31:54', '2024-07-02 04:03:42'),
('d45289a1-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'd4502354-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: d4502354-31fb-11ef-a30f-0a002700000d\nitem: B00KYDEMO\nquantity_redeemed: 2\nnet_amount: 16460.00', '2024-06-24 07:31:54', '2024-07-02 04:03:42'),
('d4528daf-31fb-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'd4502354-31fb-11ef-a30f-0a002700000d', 'Add', 'Gcash report history body record added\ngcash_report_id: d4502354-31fb-11ef-a30f-0a002700000d\nitem: GCA5H\nquantity_redeemed: 1\nnet_amount: 1600.00', '2024-06-24 07:31:54', '2024-07-02 04:03:42'),
('d64b5d23-388e-11ef-b4b1-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', 'acea8342-388e-11ef-b4b1-0a002700000d', 'Update', 'User record updated\nuser_id: acea8342-388e-11ef-b4b1-0a002700000d\nstatus: Inactive -> Active', '2024-07-04 01:22:29', '2024-07-04 02:30:15'),
('d7f52771-4652-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 04:45:09', '2024-07-20 04:45:09'),
('d9221845-31ee-11ef-a30f-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'd9220200-31ee-11ef-a30f-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-d920d1\ntotal_successful_orders: 3\ntotal_gross_sales: 24044.00\ntotal_discount: 5984.00\ntotal_outstanding_amount_1: 18060.00\nleadgen_commission_rate_base: 18060.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2022.72\ncard_payment_pg_fee: 778.50\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 24.48\ngcash_pg_fee: 44.00\ntotal_payment_gateway_fees_1: 846.98\ntotal_outstanding_amount_2: 18060.00\ntotal_commission_fees_2: 2022.72\ntotal_payment_gateway_fees_2: 846.98\nbank_fees: 10.00\ncwt_from_gross_sales: 115.99\ncwt_from_transaction_fees: 36.12\ncwt_from_pg_fees: 15.12\ntotal_amount_paid_out: 15115.55', '2024-06-24 05:58:58', '2024-07-02 04:03:42');
INSERT INTO `activity_history` (`activity_id`, `user_id`, `table_name`, `table_id`, `activity_type`, `description`, `created_at`, `updated_at`) VALUES
('db408a07-4410-11ef-951c-48e7dad87c24', NULL, 'store', 'a9610fdb-a96e-4415-919f-8e71e1b7659e', 'Add', 'Store record added\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nstore_name: Angel\'s Pizza Avida Davao\nlegal_entity_name: Figaro Coffee Systems, Inc.\nstore_address: Avida Davao Towers, C. M. Recto St., Brgy. 34, Davao City', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('db40da5c-4410-11ef-951c-48e7dad87c24', NULL, 'store', 'b745e964-eba8-4372-a940-167be6c2c227', 'Add', 'Store record added\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nstore_name: Angel\'s Pizza BGC\nlegal_entity_name: Figaro Coffee Systems, Inc.\nstore_address: N/A', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('db4177e5-4410-11ef-951c-48e7dad87c24', NULL, 'store', '67789d26-7c0f-4147-9f40-149aca3c0f9a', 'Add', 'Store record added\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nstore_name: Angel\'s Pizza Marikina\nlegal_entity_name: Figaro Coffee Systems, Inc.\nstore_address: Unit 6 Thaddeus Arcade, Gil Fernando Ave., Brgy. San Roque, Marikina City', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('db417cf9-4410-11ef-951c-48e7dad87c24', NULL, 'store', 'd61b2260-42e0-4281-be7a-bc3fb3244bd1', 'Add', 'Store record added\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nstore_name: Angel\'s Pizza Ortigas\nlegal_entity_name: Figaro Coffee Systems, Inc.\nstore_address: 102-B Hanston Bldg Emerald Ave., Ortigas Center, Brgy. San Antonio, Pasig City', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('db41800a-4410-11ef-951c-48e7dad87c24', NULL, 'store', '6cb2f0fe-253d-49c9-b52b-db44354138c8', 'Add', 'Store record added\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nstore_name: Angel\'s Pizza Sta. Maria\nlegal_entity_name: Figaro Coffee Systems, Inc.\nstore_address: N/A', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('db4182c7-4410-11ef-951c-48e7dad87c24', NULL, 'store', 'b2ce0524-02b0-4bfc-b05d-8b637ff52ff5', 'Add', 'Store record added\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nstore_name: Angel\'s Pizza Sucat\nlegal_entity_name: Figaro Coffee Systems, Inc.\nstore_address: BLK.4 Lot 21 President\'s Ave. Teoville East Village Bf Homes', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('db6abe5d-44d3-11ef-ae4c-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'db695beb-44d3-11ef-ae4c-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL and BILLABLE\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nmerchant_business_name: Taipeifoods Inc.\nmerchant_brand_name: Shi Lin\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: N/A\nsettlement_period_start: 2024-07-01\nsettlement_period_end: 2024-07-31\nsettlement_number: SR#LG2024-07-18-db695beb\ntotal_successful_orders: 2\ntotal_gross_sales: 4702.00\ntotal_discount: 500.00\ntotal_outstanding_amount_1: 4202.00\nleadgen_commission_rate_base_pretrial: 4202.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 420.20\nleadgen_commission_rate_base_billable: 2000.00\ncommission_rate_billable: 10.00%\ntotal_billable: 200.00\ntotal_commission_fees_1: 200.00\ncard_payment_pg_fee: 92.44\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 0.00\ntotal_payment_gateway_fees_1: 92.44\ntotal_outstanding_amount_2: 4202.00\ntotal_commission_fees_2: 200.00\ntotal_payment_gateway_fees_2: 92.44\nbank_fees: 10.00\nwtax_from_gross_sales: 20.55\ncwt_from_transaction_fees: 0.00\ncwt_from_pg_fees: 0.00\ntotal_amount_paid_out: 3879.01', '2024-07-18 07:03:38', '2024-07-18 07:03:38'),
('de9166b2-37bf-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'transaction', 'a6673ec0-2d50-11ef-a4d2-48e7dad87c24', 'Update', 'Transaction record updated\ntransaction_date: 2024-06-13 10:55:41 -> 2024-06-14 10:55:41', '2024-07-01 15:37:48', '2024-07-02 04:03:42'),
('dee39949-37c3-11ef-bccf-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'promo', 'dee3716e-37c3-11ef-bccf-0a002700000d', 'Add', 'Promo record added\n\npromo_code: SHILIN500\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\npromo_amount: 500\nvoucher_type: Decoupled\npromo_category: Casual Dining\npromo_group: Booky\npromo_type: Fixed discount\npromo_details: Shi Lin sample promo\nremarks: N/A\nbill_status: BILLABLE\nstart_date: 2024-04-01\nend_date: 2024-07-31', '2024-07-01 16:06:26', '2024-07-02 04:03:42'),
('dfc4a3ab-4407-11ef-951c-48e7dad87c24', NULL, 'transaction', '6c851d41-37c4-11ef-bccf-0a002700000d', 'Update', 'Transaction record updated\npromo_code: SHILIN500 -> PRESHILIN', '2024-07-17 06:43:28', '2024-07-17 06:43:28'),
('e203dbb5-4675-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '62f0f17f-4039-4993-8e64-84b03910c005', 'Update', 'Merchant record updated\nmerchant_id: 62f0f17f-4039-4993-8e64-84b03910c005', '2024-07-20 08:55:58', '2024-07-20 08:55:58'),
('e3b1c458-342d-11ef-b7ae-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'user', '6b8a15bf-2ed7-11ef-bafd-48e7dad87c24', 'Update', 'User record updated\nstatus: Inactive -> Active', '2024-06-27 02:35:17', '2024-07-02 04:03:42'),
('e4bc7553-2d4e-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'e4bbda63-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-e4bbda', '2024-06-18 08:43:54', '2024-07-02 04:03:42'),
('e4c02508-2d4e-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'e4bbda63-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: e4bbda63-2d4e-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:43:54', '2024-07-02 04:03:42'),
('e4df26c6-4649-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nmerchant_name: Shi Lin -> ', '2024-07-20 03:41:05', '2024-07-20 03:41:05'),
('e4e7a131-464a-11ef-b60e-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:48:15', '2024-07-20 03:48:15'),
('e53050aa-4414-11ef-951c-48e7dad87c24', NULL, 'transaction', '902dc726', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639053774507\"\ntransaction_date: 2024-04-20 17:53:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:16:40', '2024-07-17 08:16:40'),
('e53057ae-4414-11ef-951c-48e7dad87c24', NULL, 'transaction', '8461f2b3', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639761268466\"\ntransaction_date: 2024-04-20 11:26:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:16:40', '2024-07-17 08:16:40'),
('e53063e1-4414-11ef-951c-48e7dad87c24', NULL, 'transaction', 'dd50d96b', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639171186490\"\ntransaction_date: 2024-04-22 19:08:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:16:40', '2024-07-17 08:16:40'),
('e5312f62-4414-11ef-951c-48e7dad87c24', NULL, 'transaction', '6ea596b0', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639052772221\"\ntransaction_date: 2024-04-23 17:20:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:16:40', '2024-07-17 08:16:40'),
('e5313669-4414-11ef-951c-48e7dad87c24', NULL, 'transaction', 'eb9964e2', 'Add', 'Transaction record added\nstore_id: a9610fdb-a96e-4415-919f-8e71e1b7659e\npromo_code: UBANGELS10\ncustomer_id: \"639083241312\"\ntransaction_date: 2024-04-25 19:06:00\ngross_amount: 0.00\ndiscount: 0.00\namount_discounted: 0.00\npayment: N/A\nbill_status: BILLABLE', '2024-07-17 08:16:40', '2024-07-17 08:16:40'),
('e74f38d0-32bc-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'e74e1262-32bc-11ef-b166-48e7dad87c24', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: SR#LG2024-06-25-e74e\ntotal_successful_orders: 2\ntotal_gross_sales: 22244.00\ntotal_discount: 5784.00\ntotal_outstanding_amount_1: 16460.00\nleadgen_commission_rate_base: 16460.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 1843.52\ncard_payment_pg_fee: 0.00\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 452.66\ntotal_payment_gateway_fees_1: 452.66\ntotal_outstanding_amount_2: 16460.00\ntotal_commission_fees_2: 1843.52\ntotal_payment_gateway_fees_2: 452.66\nbank_fees: 10.00\ncwt_from_gross_sales: 108.96\ncwt_from_transaction_fees: 32.92\ncwt_from_pg_fees: 8.08\ntotal_amount_paid_out: 14085.86', '2024-06-25 06:33:58', '2024-07-02 04:03:42'),
('e7864315-464a-11ef-b60e-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d\nbusiness_address: Taipeifoods Inc. -> ', '2024-07-20 03:48:19', '2024-07-20 03:48:19'),
('e9520508-464a-11ef-b60e-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:48:22', '2024-07-20 03:48:22'),
('eb6d338b-2d4e-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'eb6c4798-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-eb6c47', '2024-06-18 08:44:05', '2024-07-02 04:03:42'),
('eb6e79d2-2d4e-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_body', 'eb6c4798-2d4e-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history body record added\ngcash_report_id: eb6c4798-2d4e-11ef-a4d2-48e7dad87c24\nitem: B00KYDEMO\nquantity_redeemed: 1\nvoucher_value: 100.00\namount: 100.00', '2024-06-18 08:44:05', '2024-07-02 04:03:42'),
('ed54e1c0-464a-11ef-b60e-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:48:29', '2024-07-20 03:48:29'),
('ee8520d1-36f9-11ef-8f86-0a002700000d', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'ee8374cc-36f9-11ef-8f86-0a002700000d', 'Add', 'Coupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_number: SR#LG2024-07-01-ee8374cc\ntotal_successful_orders: 3\ntotal_gross_sales: 37814.00\ntotal_discount: 8898.00\ntotal_outstanding_amount_1: 28916.00\nleadgen_commission_rate_base: 28916.00\ncommission_rate: 10.00%\ntotal_commission_fees_1: 2466.32\ncard_payment_pg_fee: 186.84\npaymaya_pg_fee: 0.00\ngcash_miniapp_pg_fee: 0.00\ngcash_pg_fee: 428.18\ntotal_payment_gateway_fees_1: 615.02\ntotal_outstanding_amount_2: 28916.00\ntotal_commission_fees_2: 2466.32\ntotal_payment_gateway_fees_2: 615.02\nbank_fees: 10.00\ncwt_from_gross_sales: 185.99\ncwt_from_transaction_fees: 45.38\ncwt_from_pg_fees: 10.98\ntotal_amount_paid_out: 25693.69', '2024-06-30 16:00:54', '2024-07-02 04:03:42'),
('f0e4823b-464a-11ef-b60e-48e7dad87c24', NULL, 'merchant', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Update', 'Merchant record updated\nmerchant_id: a893e292-37c3-11ef-bccf-0a002700000d', '2024-07-20 03:48:35', '2024-07-20 03:48:35'),
('f15b0edb-2d50-11ef-a4d2-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_gcash_head', 'f15a327b-2d50-11ef-a4d2-48e7dad87c24', 'Add', 'Gcash report history head record added\ngenerated_by: N/A\nmerchant_id: N/A\nmerchant_business_name: N/A\nmerchant_brand_name: N/A\nstore_id: 8946759b-1cc2-11ef-8abb-48e7dad87c24\nstore_business_name: Demo Legal Name\nstore_brand_name: B00KY Demo Store\nbusiness_address: Anywhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-05-31\nsettlement_number: 202405-f15a32', '2024-06-18 08:58:34', '2024-07-02 04:03:42'),
('f2bd42ec-45e0-11ef-9af2-48e7dad87c24', NULL, 'report_history_decoupled', 'f2bc9d99-45e0-11ef-9af2-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-19-f2bc9d99\ntotal_successful_orders: 9\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 9000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 1008.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-19 15:09:52', '2024-07-19 15:09:52'),
('f539307d-443e-11ef-951c-48e7dad87c24', NULL, 'report_history_decoupled', 'f5381776-443e-11ef-951c-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nbill_status: PRE-TRIAL and BILLABLE\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\nmerchant_business_name: Figaro Coffee Systems, Inc.\nmerchant_brand_name: Angel\'s Pizza\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: 33 Mayon St. Brgy. Malamig, Mandaluyong City\nsettlement_period_start: 2024-04-01\nsettlement_period_end: 2024-04-30\nsettlement_number: SR#LG2024-07-17-f5381776\ntotal_successful_orders: 9\ntotal_gross_sales: 0.00\ntotal_discount: 0.00\ntotal_outstanding_amount: 0.00\nleadgen_commission_rate_base_pretrial: 9000.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 1008.00\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-07-17 13:17:45', '2024-07-17 13:17:45'),
('f5809aca-32be-11ef-b166-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'report_history_coupled', 'f57fe3e7-32be-11ef-b166-48e7dad87c24', 'Add', 'Decoupled report history record added\ngenerated_by: N/A\nmerchant_id: 3606c45c-1cc2-11ef-8abb-48e7dad87c24\nmerchant_business_name: Merchant Legal Name\nmerchant_brand_name: B00KY Demo Merchant\nstore_id: N/A\nstore_business_name: N/A\nstore_brand_name: N/A\nbusiness_address: Somewhere St.\nsettlement_period_start: 2024-05-01\nsettlement_period_end: 2024-06-30\nsettlement_date: June 25, 2024\nsettlement_number: SR#LG2024-06-25-f57f\nsettlement_period: May 1-Jun 30, 2024\ntotal_successful_orders: 1\ntotal_gross_sales: 1800.00\ntotal_discount: 200.00\ntotal_net_sales: 1600.00\nleadgen_commission_rate_base_pretrial: 1600.00\ncommission_rate_pretrial: 10.00%\ntotal_pretrial: 179.20\nleadgen_commission_rate_base_billable: 0.00\ncommission_rate_billable: 10.00%\ntotal_billable: 0.00\ntotal_commission_fees: 0.00', '2024-06-25 06:48:41', '2024-07-02 04:03:42'),
('f66eafe3-4671-11ef-b60e-48e7dad87c24', NULL, 'merchant', '9f8d0113-5719-4994-bb9d-03fea73f8644', 'Add', 'Merchant record added\nmerchant_name: Banh Mi Kitchen\nmerchant_partnership_type: N/A\nlegal_entity_name: \nbusiness_address: \nemail_address: ', '2024-07-20 08:27:55', '2024-07-20 08:27:55'),
('f90f721f-4675-11ef-b60e-48e7dad87c24', '09d8d971-342e-11ef-b7ae-0a002700000d', 'merchant', '9f8d0113-5719-4994-bb9d-03fea73f8644', 'Update', 'Merchant record updated\nmerchant_id: 9f8d0113-5719-4994-bb9d-03fea73f8644', '2024-07-20 08:56:37', '2024-07-20 08:56:37'),
('f97b2689-4407-11ef-951c-48e7dad87c24', NULL, 'transaction', '6c851d41-37c4-11ef-bccf-0a002700000d', 'Update', 'Transaction record updated\nbill_status: BILLABLE -> PRE-TRIAL', '2024-07-17 06:44:11', '2024-07-17 06:44:11'),
('fb5ecc56-4412-11ef-951c-48e7dad87c24', NULL, 'fee', 'fb5e990a-4412-11ef-951c-48e7dad87c24', 'Add', 'Fee record added\nmerchant_id: f04538ac-2008-403b-b0f7-4f4d49a17fda\npaymaya_credit_card: 2.50\npaymaya: 2.00\ngcash: 2.00\ngcash_miniapp: 2.00\nmaya_checkout: 2.50\nmaya: 2.50\nlead_gen_commission: 10.00\ncommission_type: VAT Exc\nis_cwt_rate_computed: 0', '2024-07-17 08:02:58', '2024-07-17 08:02:58'),
('fd549053-4407-11ef-951c-48e7dad87c24', NULL, 'transaction', '6c851d41-37c4-11ef-bccf-0a002700000d', 'Update', 'Transaction record updated\npromo_code: PRESHILIN -> SHILIN500', '2024-07-17 06:44:17', '2024-07-17 06:44:17');

--
-- Triggers `activity_history`
--
DELIMITER $$
CREATE TRIGGER `generate_activity_id` BEFORE INSERT ON `activity_history` FOR EACH ROW BEGIN
    SET NEW.activity_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updated_at_activity_history` BEFORE UPDATE ON `activity_history` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `activity_history_view`
-- (See below for the actual view)
--
CREATE TABLE `activity_history_view` (
`activity_history_id` varchar(8)
,`user_id` varchar(8)
,`user_name` varchar(100)
,`table_name` varchar(50)
,`table_id` varchar(8)
,`column_name` varchar(255)
,`activity_type` enum('Add','Update','Delete','Login')
,`description` text
,`time_ago` varchar(79)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `fee`
--

CREATE TABLE `fee` (
  `fee_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `paymaya_credit_card` decimal(4,2) NOT NULL DEFAULT 0.00,
  `gcash` decimal(4,2) NOT NULL DEFAULT 0.00,
  `gcash_miniapp` decimal(4,2) NOT NULL DEFAULT 0.00,
  `paymaya` decimal(4,2) NOT NULL DEFAULT 0.00,
  `maya_checkout` decimal(4,2) NOT NULL DEFAULT 0.00,
  `maya` decimal(4,2) NOT NULL DEFAULT 0.00,
  `lead_gen_commission` decimal(4,2) NOT NULL DEFAULT 0.00,
  `commission_type` enum('VAT Inc','VAT Exc') NOT NULL,
  `cwt_rate` decimal(4,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fee`
--

INSERT INTO `fee` (`fee_id`, `merchant_id`, `paymaya_credit_card`, `gcash`, `gcash_miniapp`, `paymaya`, `maya_checkout`, `maya`, `lead_gen_commission`, `commission_type`, `cwt_rate`, `created_at`, `updated_at`) VALUES
('596e3a87-37c5-11ef-bccf-0a002700000d', 'a893e292-37c3-11ef-bccf-0a002700000d', 2.20, 2.00, 2.00, 2.00, 2.20, 2.20, 10.00, 'VAT Inc', 0.00, '2024-07-01 16:17:02', '2024-07-17 06:33:33'),
('fb5e990a-4412-11ef-951c-48e7dad87c24', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 2.50, 2.00, 2.00, 2.00, 2.50, 2.50, 10.00, 'VAT Exc', 0.00, '2024-07-17 08:02:58', '2024-07-17 08:02:58');

--
-- Triggers `fee`
--
DELIMITER $$
CREATE TRIGGER `before_insert_fee` BEFORE INSERT ON `fee` FOR EACH ROW BEGIN
  IF NEW.maya_checkout != 0.00 THEN
        SET NEW.paymaya_credit_card = NEW.maya_checkout;
        SET NEW.maya = NEW.maya_checkout;
    ELSEIF NEW.paymaya_credit_card != 0.00 THEN
        SET NEW.maya_checkout = NEW.paymaya_credit_card;
        SET NEW.maya = NEW.paymaya_credit_card;
    ELSEIF NEW.maya != 0.00 THEN
        SET NEW.paymaya_credit_card = NEW.maya;
        SET NEW.maya_checkout = NEW.maya;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_fee` BEFORE UPDATE ON `fee` FOR EACH ROW BEGIN
    IF NEW.maya_checkout != OLD.maya_checkout THEN
        SET NEW.paymaya_credit_card = NEW.maya_checkout;
        SET NEW.maya = NEW.maya_checkout;
    ELSEIF NEW.paymaya_credit_card != OLD.paymaya_credit_card THEN
        SET NEW.maya_checkout = NEW.paymaya_credit_card;
        SET NEW.maya = NEW.paymaya_credit_card;
    ELSEIF NEW.maya != OLD.maya THEN
        SET NEW.paymaya_credit_card = NEW.maya;
        SET NEW.maya_checkout = NEW.maya;
    END IF;
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
  '\n','commission_type: ', IFNULL(NEW.commission_type, 'N/A'),
  '\n','cwt_rate: ', IFNULL(NEW.cwt_rate, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('fee', NEW.fee_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `fee_update_log` AFTER UPDATE ON `fee` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Fee record updated\n';

  SET description = CONCAT(description, 'merchant_id: ', NEW.merchant_id, '\n');
  
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
  
  IF OLD.cwt_rate != NEW.cwt_rate THEN
    SET description = CONCAT(description, 'cwt_rate: ', OLD.cwt_rate, ' -> ', NEW.cwt_rate, '\n');
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
  
  IF OLD.cwt_rate != NEW.cwt_rate THEN
    INSERT INTO fee_history (fee_history_id, fee_id, column_name, old_value, new_value)
    VALUES (UUID(), NEW.fee_id, 'cwt_rate', OLD.cwt_rate, NEW.cwt_rate);
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updated_at_fee` BEFORE UPDATE ON `fee` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed_by` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fee_history`
--

INSERT INTO `fee_history` (`fee_history_id`, `fee_id`, `column_name`, `old_value`, `new_value`, `changed_at`, `changed_by`) VALUES
('7d41172a-4406-11ef-951c-48e7dad87c24', '596e3a87-37c5-11ef-bccf-0a002700000d', 'is_cwt_rate_computed', '1', '0', '2024-07-17 06:33:33', NULL);

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
  `email_address` text DEFAULT NULL,
  `sales` varchar(36) DEFAULT NULL,
  `account_manager` varchar(36) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant`
--

INSERT INTO `merchant` (`merchant_id`, `merchant_name`, `merchant_partnership_type`, `legal_entity_name`, `business_address`, `email_address`, `sales`, `account_manager`, `created_at`, `updated_at`) VALUES
('62f0f17f-4039-4993-8e64-84b03910c005', 'Auntie Anne\'s', NULL, 'Pretiolas Philippines Inc.', 'NO OSC', NULL, NULL, NULL, '2024-07-20 08:23:09', '2024-07-20 08:55:58'),
('778a5700-678b-489f-9be2-22a96bab523c', 'Mesa', NULL, NULL, NULL, NULL, NULL, 'b1a44bae-3825-11ef-9d23-0a002700000d', '2024-07-20 08:47:49', '2024-07-20 08:56:50'),
('9f8d0113-5719-4994-bb9d-03fea73f8644', 'Banh Mi Kitchen', 'Primary', NULL, NULL, NULL, 'b1a44bae-3825-11ef-9d23-0a002700000d', NULL, '2024-07-20 08:27:55', '2024-07-20 08:56:37'),
('a893e292-37c3-11ef-bccf-0a002700000d', 'Shi Lin', 'Primary', 'Taipeifoods Inc.', NULL, NULL, '031c090d-3826-11ef-9d23-0a002700000d', NULL, '2024-07-01 16:04:55', '2024-07-20 04:45:09'),
('f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Angel\'s Pizza', 'Primary', 'Figaro Coffee Systems, Inc.', '33 Mayon St. Brgy. Malamig, Mandaluyong City', 'cookie@booky.ph', NULL, NULL, '2024-07-17 07:38:33', '2024-07-17 07:56:41');

--
-- Triggers `merchant`
--
DELIMITER $$
CREATE TRIGGER `generate_merchant_id` BEFORE INSERT ON `merchant` FOR EACH ROW BEGIN
    IF NEW.merchant_id IS NULL OR NEW.merchant_id = '' 
    THEN SET NEW.merchant_id = UUID();
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
  
  SET description = CONCAT(description, 'merchant_id: ', NEW.merchant_id, '\n');

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
DELIMITER $$
CREATE TRIGGER `updated_at_merchant` BEFORE UPDATE ON `merchant` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `merchant_view`
-- (See below for the actual view)
--
CREATE TABLE `merchant_view` (
`merchant_id` varchar(36)
,`merchant_name` varchar(255)
,`merchant_partnership_type` varchar(24)
,`legal_entity_name` varchar(255)
,`business_address` mediumtext
,`email_address` mediumtext
,`sales_id` varchar(36)
,`sales` varchar(100)
,`account_manager_id` varchar(36)
,`account_manager` varchar(100)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `promo`
--

CREATE TABLE `promo` (
  `promo_id` varchar(36) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `promo_amount` int(11) NOT NULL DEFAULT 0,
  `voucher_type` enum('Coupled','Decoupled') DEFAULT NULL,
  `promo_category` enum('Grab & Go','Casual Dining') DEFAULT NULL,
  `promo_group` enum('Booky','Gcash','Unionbank','Gcash/Booky','UB/Booky') NOT NULL,
  `promo_type` enum('BOGO','Bundle','Fixed discount','Free item','Fixed discount, Free item','Percent discount','X for Y') NOT NULL,
  `promo_details` text NOT NULL,
  `remarks` text DEFAULT NULL,
  `bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `remarks2` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promo`
--

INSERT INTO `promo` (`promo_id`, `promo_code`, `merchant_id`, `promo_amount`, `voucher_type`, `promo_category`, `promo_group`, `promo_type`, `promo_details`, `remarks`, `bill_status`, `start_date`, `end_date`, `remarks2`, `created_at`, `updated_at`) VALUES
('dee3716e-37c3-11ef-bccf-0a002700000d', 'SHILIN500', 'a893e292-37c3-11ef-bccf-0a002700000d', 500, 'Coupled', 'Casual Dining', 'Booky', 'Fixed discount', 'Shi Lin sample promo', NULL, 'BILLABLE', '2024-04-01', '2024-07-31', NULL, '2024-07-01 16:06:26', '2024-07-17 06:31:03'),
('5146a532-4413-11ef-951c-48e7dad87c24', 'UBANGELS10', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 1000, 'Decoupled', 'Casual Dining', 'Unionbank', 'Percent discount', 'Get 10% off with a minimum spend of ₱1,000', 'free, min spend 1000', 'PRE-TRIAL', '2024-04-19', '2024-07-19', NULL, '2024-07-17 08:05:23', '2024-07-17 08:05:23');

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

  SET description = CONCAT(description, 'merchant_id: ', NEW.merchant_id, '\n');
  
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
DELIMITER $$
CREATE TRIGGER `updated_at_promo` BEFORE UPDATE ON `promo` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed_by` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `bill_status` enum('PRE-TRIAL','BILLABLE','PRE-TRIAL and BILLABLE') NOT NULL,
  `merchant_id` varchar(36) DEFAULT NULL,
  `merchant_business_name` varchar(255) DEFAULT NULL,
  `merchant_brand_name` varchar(255) DEFAULT NULL,
  `store_id` varchar(36) DEFAULT NULL,
  `store_business_name` varchar(255) DEFAULT NULL,
  `store_brand_name` varchar(255) DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `settlement_period_start` date NOT NULL,
  `settlement_period_end` date NOT NULL,
  `settlement_date` varchar(30) NOT NULL,
  `settlement_number` varchar(25) NOT NULL,
  `settlement_period` varchar(30) NOT NULL,
  `total_successful_orders` int(11) NOT NULL,
  `total_gross_sales` decimal(10,2) NOT NULL,
  `total_discount` decimal(10,2) NOT NULL,
  `total_outstanding_amount_1` decimal(10,2) NOT NULL,
  `leadgen_commission_rate_base_pretrial` decimal(10,2) NOT NULL,
  `commission_rate_pretrial` varchar(10) NOT NULL,
  `total_pretrial` decimal(10,2) NOT NULL,
  `leadgen_commission_rate_base_billable` decimal(10,2) NOT NULL,
  `commission_rate_billable` varchar(10) NOT NULL,
  `total_billable` decimal(10,2) NOT NULL,
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
  `wtax_from_gross_sales` decimal(10,2) NOT NULL,
  `cwt_from_transaction_fees` decimal(10,2) NOT NULL,
  `cwt_from_pg_fees` decimal(10,2) NOT NULL,
  `total_amount_paid_out` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `report_history_coupled`
--

INSERT INTO `report_history_coupled` (`coupled_report_id`, `generated_by`, `bill_status`, `merchant_id`, `merchant_business_name`, `merchant_brand_name`, `store_id`, `store_business_name`, `store_brand_name`, `business_address`, `settlement_period_start`, `settlement_period_end`, `settlement_date`, `settlement_number`, `settlement_period`, `total_successful_orders`, `total_gross_sales`, `total_discount`, `total_outstanding_amount_1`, `leadgen_commission_rate_base_pretrial`, `commission_rate_pretrial`, `total_pretrial`, `leadgen_commission_rate_base_billable`, `commission_rate_billable`, `total_billable`, `total_commission_fees_1`, `card_payment_pg_fee`, `paymaya_pg_fee`, `gcash_miniapp_pg_fee`, `gcash_pg_fee`, `total_payment_gateway_fees_1`, `total_outstanding_amount_2`, `total_commission_fees_2`, `total_payment_gateway_fees_2`, `bank_fees`, `wtax_from_gross_sales`, `cwt_from_transaction_fees`, `cwt_from_pg_fees`, `total_amount_paid_out`, `created_at`, `updated_at`) VALUES
('7a22c391-465e-11ef-b60e-48e7dad87c24', NULL, 'PRE-TRIAL and BILLABLE', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Taipeifoods Inc.', 'Shi Lin', NULL, NULL, NULL, NULL, '2024-07-01', '2024-07-30', 'July 20, 2024', 'SR#LG2024-07-20-7a22c391', 'July 1-30, 2024', 2, 4702.00, 500.00, 4202.00, 4202.00, '10.00%', 420.20, 2000.00, '10.00%', 200.00, 200.00, 92.44, 0.00, 0.00, 0.00, 92.44, 4202.00, 200.00, 92.44, 10.00, 20.55, 0.00, 0.00, 3879.01, '2024-07-20 06:08:26', '2024-07-20 06:08:26'),
('7a52e8e9-464d-11ef-b60e-48e7dad87c24', NULL, 'BILLABLE', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Taipeifoods Inc.', 'Shi Lin', NULL, NULL, NULL, NULL, '2024-07-01', '2024-07-30', 'July 20, 2024', 'SR#LG2024-07-20-7a52e8e9', 'July 1-30, 2024', 1, 0.00, 0.00, 0.00, 0.00, '10.00%', 0.00, 2000.00, '10.00%', 200.00, 200.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 200.00, 0.00, 10.00, 0.00, 0.00, 0.00, -210.00, '2024-07-20 04:06:45', '2024-07-20 04:06:45'),
('db695beb-44d3-11ef-ae4c-48e7dad87c24', NULL, 'PRE-TRIAL and BILLABLE', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Taipeifoods Inc.', 'Shi Lin', NULL, NULL, NULL, NULL, '2024-07-01', '2024-07-31', 'July 18, 2024', 'SR#LG2024-07-18-db695beb', 'July 1-31, 2024', 2, 4702.00, 500.00, 4202.00, 4202.00, '10.00%', 420.20, 2000.00, '10.00%', 200.00, 200.00, 92.44, 0.00, 0.00, 0.00, 92.44, 4202.00, 200.00, 92.44, 10.00, 20.55, 0.00, 0.00, 3879.01, '2024-07-18 07:03:38', '2024-07-18 07:03:38');

--
-- Triggers `report_history_coupled`
--
DELIMITER $$
CREATE TRIGGER `report_history_coupled_insert_log` BEFORE INSERT ON `report_history_coupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Coupled report history record added\n',
  'generated_by: ', IFNULL(NEW.generated_by, 'N/A'), 
  '\n','bill_status: ', IFNULL(NEW.bill_status, 'N/A'),
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
                           
  '\n','leadgen_commission_rate_base_pretrial: ', IFNULL(NEW.leadgen_commission_rate_base_pretrial, 'N/A'),
  '\n','commission_rate_pretrial: ', IFNULL(NEW.commission_rate_pretrial, 'N/A'),
  '\n','total_pretrial: ', IFNULL(NEW.total_pretrial, 'N/A'),
                           
  '\n','leadgen_commission_rate_base_billable: ', IFNULL(NEW.leadgen_commission_rate_base_billable, 'N/A'),
  '\n','commission_rate_billable: ', IFNULL(NEW.commission_rate_billable, 'N/A'),
  '\n','total_billable: ', IFNULL(NEW.total_billable, 'N/A'),
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

  '\n','wtax_from_gross_sales: ', IFNULL(NEW.wtax_from_gross_sales, 'N/A'),
  '\n','cwt_from_transaction_fees: ', IFNULL(NEW.cwt_from_transaction_fees, 'N/A'),
  '\n','cwt_from_pg_fees: ', IFNULL(NEW.cwt_from_pg_fees, 'N/A'),
  '\n','total_amount_paid_out: ', IFNULL(NEW.total_amount_paid_out, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_coupled', NEW.coupled_report_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `report_history_coupled_update_log` BEFORE UPDATE ON `report_history_coupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Coupled report history record updated\n';

  IF OLD.generated_by != NEW.generated_by THEN
    SET description = CONCAT(description, 'generated_by: ', OLD.generated_by, ' -> ', NEW.generated_by, '\n');
  END IF;

  IF OLD.bill_status != NEW.bill_status THEN
    SET description = CONCAT(description, 'bill_status: ', OLD.bill_status, ' -> ', NEW.bill_status, '\n');
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
  
  IF OLD.wtax_from_gross_sales != NEW.wtax_from_gross_sales THEN
    SET description = CONCAT(description, 'wtax_from_gross_sales: ', OLD.wtax_from_gross_sales, ' -> ', NEW.wtax_from_gross_sales, '\n');
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
DELIMITER $$
CREATE TRIGGER `updated_at_report_history_coupled` BEFORE UPDATE ON `report_history_coupled` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
  `bill_status` enum('PRE-TRIAL','BILLABLE','PRE-TRIAL and BILLABLE') NOT NULL,
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
  `settlement_number` varchar(25) NOT NULL,
  `settlement_period` varchar(30) NOT NULL,
  `total_successful_orders` int(11) NOT NULL,
  `total_gross_sales` decimal(10,2) NOT NULL,
  `total_discount` decimal(10,2) NOT NULL,
  `total_outstanding_amount` decimal(10,2) NOT NULL,
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

INSERT INTO `report_history_decoupled` (`decoupled_report_id`, `generated_by`, `bill_status`, `merchant_id`, `merchant_business_name`, `merchant_brand_name`, `store_id`, `store_business_name`, `store_brand_name`, `business_address`, `settlement_period_start`, `settlement_period_end`, `settlement_date`, `settlement_number`, `settlement_period`, `total_successful_orders`, `total_gross_sales`, `total_discount`, `total_outstanding_amount`, `leadgen_commission_rate_base_pretrial`, `commission_rate_pretrial`, `total_pretrial`, `leadgen_commission_rate_base_billable`, `commission_rate_billable`, `total_billable`, `total_commission_fees`, `created_at`, `updated_at`) VALUES
('1f00bc47-45dc-11ef-9af2-48e7dad87c24', NULL, 'PRE-TRIAL and BILLABLE', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Figaro Coffee Systems, Inc.', 'Angel\'s Pizza', NULL, NULL, NULL, '33 Mayon St. Brgy. Malamig, Mandaluyong City', '2024-04-01', '2024-04-30', 'July 19, 2024', 'SR#LG2024-07-19-1f00bc47', 'April 1-30, 2024', 8, 0.00, 0.00, 0.00, 8000.00, '10.00%', 896.00, 0.00, '10.00%', 0.00, 0.00, '2024-07-19 14:35:18', '2024-07-19 14:35:18'),
('5dade388-45e3-11ef-9af2-48e7dad87c24', NULL, 'PRE-TRIAL', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Figaro Coffee Systems, Inc.', 'Angel\'s Pizza', NULL, NULL, NULL, '33 Mayon St. Brgy. Malamig, Mandaluyong City', '2024-04-01', '2024-04-30', 'July 19, 2024', 'SR#LG2024-07-19-5dade388', 'April 1-30, 2024', 9, 0.00, 0.00, 0.00, 9000.00, '10.00%', 1008.00, 0.00, '10.00%', 0.00, 0.00, '2024-07-19 15:27:10', '2024-07-19 15:27:10'),
('8ad37df2-45db-11ef-9af2-48e7dad87c24', NULL, 'PRE-TRIAL', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Figaro Coffee Systems, Inc.', 'Angel\'s Pizza', NULL, NULL, NULL, '33 Mayon St. Brgy. Malamig, Mandaluyong City', '2024-04-01', '2024-04-30', 'July 19, 2024', 'SR#LG2024-07-19-8ad37df2', 'April 1-30, 2024', 8, 0.00, 0.00, 0.00, 8000.00, '10.00%', 896.00, 0.00, '10.00%', 0.00, 0.00, '2024-07-19 14:31:10', '2024-07-19 14:31:10'),
('ad011b0d-45e8-11ef-9af2-48e7dad87c24', NULL, 'PRE-TRIAL', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Figaro Coffee Systems, Inc.', 'Angel\'s Pizza', NULL, NULL, NULL, '33 Mayon St. Brgy. Malamig, Mandaluyong City', '2024-04-01', '2024-04-30', 'July 20, 2024', 'SR#LG2024-07-20-ad011b0d', 'April 1-30, 2024', 9, 0.00, 0.00, 0.00, 9000.00, '10.00%', 1008.00, 0.00, '10.00%', 0.00, 0.00, '2024-07-19 16:05:11', '2024-07-19 16:05:11');

--
-- Triggers `report_history_decoupled`
--
DELIMITER $$
CREATE TRIGGER `report_history_decoupled_insert_log` BEFORE INSERT ON `report_history_decoupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Decoupled report history record added\n',
  'generated_by: ', IFNULL(NEW.generated_by, 'N/A'), 
  '\n','bill_status: ', IFNULL(NEW.bill_status, 'N/A'),
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
  '\n','total_outstanding_amount: ', IFNULL(NEW.total_outstanding_amount, 'N/A'),
                           
  '\n','leadgen_commission_rate_base_pretrial: ', IFNULL(NEW.leadgen_commission_rate_base_pretrial, 'N/A'),
  '\n','commission_rate_pretrial: ', IFNULL(NEW.commission_rate_pretrial, 'N/A'),
  '\n','total_pretrial: ', IFNULL(NEW.total_pretrial, 'N/A'),
                           
  '\n','leadgen_commission_rate_base_billable: ', IFNULL(NEW.leadgen_commission_rate_base_billable, 'N/A'),
  '\n','commission_rate_billable: ', IFNULL(NEW.commission_rate_billable, 'N/A'),
  '\n','total_billable: ', IFNULL(NEW.total_billable, 'N/A'),
                           
  '\n','total_commission_fees: ', IFNULL(NEW.total_commission_fees, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_decoupled', NEW.decoupled_report_id, 'Add', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `report_history_decoupled_update_log` AFTER UPDATE ON `report_history_decoupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = 'Deoupled report history record updated\n';

  IF OLD.generated_by != NEW.generated_by THEN
    SET description = CONCAT(description, 'generated_by: ', OLD.generated_by, ' -> ', NEW.generated_by, '\n');
  END IF;
  
  IF OLD.bill_status != NEW.bill_status THEN
    SET description = CONCAT(description, 'bill_status: ', OLD.bill_status, ' -> ', NEW.bill_status, '\n');
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
  
  IF OLD.total_outstanding_amount != NEW.total_outstanding_amount THEN
    SET description = CONCAT(description, 'total_outstanding_amount: ', OLD.total_outstanding_amount, ' -> ', NEW.total_outstanding_amount, '\n');
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
DELIMITER $$
CREATE TRIGGER `updated_at_report_history_decoupled` BEFORE UPDATE ON `report_history_decoupled` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
DELIMITER $$
CREATE TRIGGER `updated_at_report_gcash_body` BEFORE UPDATE ON `report_history_gcash_body` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
  `bill_status` enum('PRE-TRIAL','BILLABLE','PRE-TRIAL and BILLABLE') NOT NULL,
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
  `settlement_number` varchar(25) NOT NULL,
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
-- Triggers `report_history_gcash_head`
--
DELIMITER $$
CREATE TRIGGER `report_history_gcash_head_insert_log` AFTER INSERT ON `report_history_gcash_head` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Gcash report history head record added\n',
  'generated_by: ', IFNULL(NEW.generated_by, 'N/A'), 
  '\n','bill_status: ', IFNULL(NEW.bill_status, 'N/A'),
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
  
  IF OLD.bill_status != NEW.bill_status THEN
    SET description = CONCAT(description, 'bill_status: ', OLD.bill_status, ' -> ', NEW.bill_status, '\n');
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
DELIMITER $$
CREATE TRIGGER `updated_at_report_gcash_head` BEFORE UPDATE ON `report_history_gcash_head` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
  `store_address` varchar(250) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `store`
--

INSERT INTO `store` (`store_id`, `merchant_id`, `store_name`, `legal_entity_name`, `store_address`, `created_at`, `updated_at`) VALUES
('67789d26-7c0f-4147-9f40-149aca3c0f9a', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Angel\'s Pizza Marikina', 'Figaro Coffee Systems, Inc.', 'Unit 6 Thaddeus Arcade, Gil Fernando Ave., Brgy. San Roque, Marikina City', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('6cb2f0fe-253d-49c9-b52b-db44354138c8', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Angel\'s Pizza Sta. Maria', 'Figaro Coffee Systems, Inc.', NULL, '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('a9610fdb-a96e-4415-919f-8e71e1b7659e', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Angel\'s Pizza Avida Davao', 'Figaro Coffee Systems, Inc.', 'Avida Davao Towers, C. M. Recto St., Brgy. 34, Davao City', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('b2ce0524-02b0-4bfc-b05d-8b637ff52ff5', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Angel\'s Pizza Sucat', 'Figaro Coffee Systems, Inc.', 'BLK.4 Lot 21 President\'s Ave. Teoville East Village Bf Homes', '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('b745e964-eba8-4372-a940-167be6c2c227', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Angel\'s Pizza BGC', 'Figaro Coffee Systems, Inc.', NULL, '2024-07-17 07:47:46', '2024-07-17 07:47:46'),
('b8af69b1-37c3-11ef-bccf-0a002700000d', 'a893e292-37c3-11ef-bccf-0a002700000d', 'Shi Lin Branch', 'Taipeifoods Inc.', '2100 ID Building, Don Chino Roces extension, Brgy. Magallanes, Makati City', '2024-07-01 16:05:22', '2024-07-17 11:04:13'),
('d61b2260-42e0-4281-be7a-bc3fb3244bd1', 'f04538ac-2008-403b-b0f7-4f4d49a17fda', 'Angel\'s Pizza Ortigas', 'Figaro Coffee Systems, Inc.', '102-B Hanston Bldg Emerald Ave., Ortigas Center, Brgy. San Antonio, Pasig City', '2024-07-17 07:47:46', '2024-07-17 07:47:46');

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

  SET description = CONCAT(description, 'merchant_id: ', NEW.merchant_id, '\n');

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
DELIMITER $$
CREATE TRIGGER `updated_at_store` BEFORE UPDATE ON `store` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
  `customer_id` varchar(14) DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `transaction_date` datetime NOT NULL,
  `gross_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `amount_discounted` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya') DEFAULT NULL,
  `comm_rate_base` decimal(10,2) NOT NULL,
  `bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`transaction_id`, `store_id`, `promo_code`, `customer_id`, `customer_name`, `transaction_date`, `gross_amount`, `discount`, `amount_discounted`, `payment`, `comm_rate_base`, `bill_status`, `created_at`, `updated_at`) VALUES
('0f1b2d4d', '6cb2f0fe-253d-49c9-b52b-db44354138c8', 'UBANGELS10', '\"639225334747\"', NULL, '2024-04-26 19:10:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:19:27', '2024-07-17 11:32:43'),
('4a1ea5f4-37c4-11ef-bccf-0a002700000d', 'b8af69b1-37c3-11ef-bccf-0a002700000d', 'SHILIN500', '\"639987654321\"', 'El Sa', '2024-07-01 00:08:18', 0.00, 0.00, 0.00, NULL, 2000.00, 'BILLABLE', '2024-07-01 16:09:26', '2024-07-01 16:18:26'),
('6c851d41-37c4-11ef-bccf-0a002700000d', 'b8af69b1-37c3-11ef-bccf-0a002700000d', 'SHILIN500', '\"639574848321\"', 'Ay Mee', '2024-07-30 18:09:29', 4702.00, 500.00, 4202.00, 'maya_checkout', 4202.00, 'PRE-TRIAL', '2024-07-01 16:10:24', '2024-07-17 06:44:17'),
('6ea596b0', 'b2ce0524-02b0-4bfc-b05d-8b637ff52ff5', 'UBANGELS10', '\"639052772221\"', NULL, '2024-04-23 17:20:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:16:40', '2024-07-17 11:31:13'),
('8461f2b3', 'a9610fdb-a96e-4415-919f-8e71e1b7659e', 'UBANGELS10', '\"639761268466\"', 'MONIQUE DIMPLE ZENG', '2024-04-20 11:26:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:16:40', '2024-07-17 08:27:16'),
('902dc726', 'a9610fdb-a96e-4415-919f-8e71e1b7659e', 'UBANGELS10', '\"639053774507\"', NULL, '2024-04-20 17:53:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:16:40', '2024-07-17 08:27:16'),
('abf475bf', 'b745e964-eba8-4372-a940-167be6c2c227', 'UBANGELS10', '\"639776077101\"', 'YU MA', '2024-04-27 20:33:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:19:27', '2024-07-17 11:33:00'),
('d0a90e98', 'b745e964-eba8-4372-a940-167be6c2c227', 'UBANGELS10', '\"639776077101\"', 'YU MA', '2024-04-30 13:34:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:19:27', '2024-07-19 14:30:17'),
('d67668ed', 'd61b2260-42e0-4281-be7a-bc3fb3244bd1', 'UBANGELS10', '\"639064050757\"', NULL, '2024-04-26 15:38:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:19:27', '2024-07-17 11:32:28'),
('dd50d96b', '6cb2f0fe-253d-49c9-b52b-db44354138c8', 'UBANGELS10', '\"639171186490\"', NULL, '2024-04-22 19:08:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:16:40', '2024-07-17 11:30:48'),
('eb9964e2', '67789d26-7c0f-4147-9f40-149aca3c0f9a', 'UBANGELS10', '\"639083241312\"', NULL, '2024-04-25 19:06:00', 0.00, 0.00, 0.00, NULL, 1000.00, 'PRE-TRIAL', '2024-07-17 08:16:40', '2024-07-17 11:31:47');

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
DELIMITER $$
CREATE TRIGGER `updated_at_transaction` BEFORE UPDATE ON `transaction` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
,`Formatted Transaction Date` varchar(81)
,`Transaction Date` varchar(10)
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
,`Promo Type` enum('BOGO','Bundle','Fixed discount','Free item','Fixed discount, Free item','Percent discount','X for Y')
,`Gross Amount` decimal(10,2)
,`Discount` decimal(10,2)
,`Cart Amount` decimal(10,2)
,`Mode of Payment` varchar(19)
,`Bill Status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE')
,`Comm Rate Base` decimal(10,2)
,`Commission Type` varchar(50)
,`Commission Rate` varchar(51)
,`Commission Amount` double(19,2)
,`Total Billing` double(19,2)
,`PG Fee Rate` varchar(51)
,`PG Fee Amount` double(19,2)
,`CWT Rate` decimal(4,2)
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
  `department` enum('Admin','Finance','Operations') DEFAULT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `email_address`, `password`, `name`, `type`, `department`, `status`, `created_at`, `updated_at`) VALUES
('031c090d-3826-11ef-9d23-0a002700000d', 'rominna@booky.ph', '$2y$10$Q49RiBWN5YY4ifaslsE8he7XHED6Jr0vyQ7s5Izij4bg57oneXY9W', 'Rominna Angeline R. Raymundo', 'User', 'Operations', 'Active', '2024-07-02 03:48:58', '2024-07-04 01:17:51'),
('09d8d971-342e-11ef-b7ae-0a002700000d', 'admin@booky.ph', '$2y$10$QPrvim.Z8xAZjI2TOLASWeXwuaxjn4dzob7tLlB90Vp9PUpa8XyE2', 'Admin', 'Admin', 'Admin', 'Active', '2024-06-27 02:36:21', '2024-07-04 01:17:59'),
('acea8342-388e-11ef-b4b1-0a002700000d', 'cookie@booky.ph', '$2y$10$dRffZ66tPS8hHDmkIWssSOOlk21L1/H3g1lOz6J8uxldv.BM.5rci', 'Cookie', 'User', 'Finance', 'Active', '2024-07-04 01:21:20', '2024-07-04 01:22:29'),
('b1a44bae-3825-11ef-9d23-0a002700000d', 'ben@booky.ph', '$2y$10$nNJgZho7u3EoVduIQvNqquhWT/mrR2j6foaVuAHx9QpOcrdxG14ce', 'Ben Wintle', 'User', 'Operations', 'Active', '2024-07-02 03:46:41', '2024-07-04 01:18:04');

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
CREATE TRIGGER `updated_at_user` BEFORE UPDATE ON `user` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
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
  
  SET description = CONCAT(description, 'user_id: ', NEW.user_id, '\n');

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
-- Structure for view `activity_history_view`
--
DROP TABLE IF EXISTS `activity_history_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `activity_history_view`  AS SELECT substr(`a`.`activity_id`,1,8) AS `activity_history_id`, substr(coalesce(`a`.`user_id`,'xxxxxxxx'),1,8) AS `user_id`, coalesce(`u`.`name`,'Unknown user') AS `user_name`, `a`.`table_name` AS `table_name`, substr(coalesce(case when `a`.`table_name` = 'merchant' then `m`.`merchant_id` when `a`.`table_name` = 'store' then `s`.`store_id` when `a`.`table_name` = 'promo' then `p`.`promo_id` when `a`.`table_name` = 'promo_history' then `ph`.`promo_history_id` when `a`.`table_name` = 'fee' then `f`.`fee_id` when `a`.`table_name` = 'fee_history' then `fh`.`fee_history_id` when `a`.`table_name` = 'transaction' then `t`.`transaction_id` when `a`.`table_name` = 'user' then `u2`.`user_id` when `a`.`table_name` = 'report_history_coupled' then `rhc`.`coupled_report_id` when `a`.`table_name` = 'report_history_decoupled' then `rhd`.`decoupled_report_id` when `a`.`table_name` = 'report_history_gcash_head' then `rhgh`.`gcash_report_id` when `a`.`table_name` = 'report_history_gcash_body' then `rhgb`.`gcash_report_body_id` else NULL end,'Deleted'),1,8) AS `table_id`, coalesce(case when `a`.`table_name` = 'merchant' then `m`.`merchant_name` when `a`.`table_name` = 'store' then `s`.`store_name` when `a`.`table_name` = 'promo' then `p`.`promo_code` when `a`.`table_name` = 'promo_history' then `ph`.`promo_code` when `a`.`table_name` = 'fee' then `fm`.`merchant_name` when `a`.`table_name` = 'fee_history' then `fhm`.`merchant_name` when `a`.`table_name` = 'transaction' then `t`.`customer_id` when `a`.`table_name` = 'user' then `u2`.`name` when `a`.`table_name` = 'report_history_coupled' then `rhc`.`settlement_number` when `a`.`table_name` = 'report_history_decoupled' then `rhd`.`settlement_number` when `a`.`table_name` = 'report_history_gcash_head' then `rhgh`.`settlement_number` when `a`.`table_name` = 'report_history_gcash_body' then `rhgh`.`settlement_number` else NULL end,'Deleted') AS `column_name`, `a`.`activity_type` AS `activity_type`, `a`.`description` AS `description`, CASE WHEN timestampdiff(SECOND,`a`.`created_at`,current_timestamp()) < 60 THEN concat(timestampdiff(SECOND,`a`.`created_at`,current_timestamp()),' second',if(timestampdiff(SECOND,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago') WHEN timestampdiff(MINUTE,`a`.`created_at`,current_timestamp()) < 60 THEN concat(timestampdiff(MINUTE,`a`.`created_at`,current_timestamp()),' minute',if(timestampdiff(MINUTE,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago') WHEN timestampdiff(HOUR,`a`.`created_at`,current_timestamp()) < 24 THEN concat(timestampdiff(HOUR,`a`.`created_at`,current_timestamp()),' hour',if(timestampdiff(HOUR,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago') WHEN timestampdiff(DAY,`a`.`created_at`,current_timestamp()) < 7 THEN concat(timestampdiff(DAY,`a`.`created_at`,current_timestamp()),' day',if(timestampdiff(DAY,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago') ELSE date_format(`a`.`created_at`,'%M %d at %l:%i %p') END AS `time_ago`, `a`.`created_at` AS `created_at`, `a`.`updated_at` AS `updated_at` FROM (((((((((((((((((`activity_history` `a` left join `user` `u` on(`u`.`user_id` = `a`.`user_id`)) left join `merchant` `m` on(`a`.`table_id` = `m`.`merchant_id`)) left join `store` `s` on(`a`.`table_id` = `s`.`store_id`)) left join `promo` `p` on(`a`.`table_id` = `p`.`promo_id`)) left join `promo_history` `ph` on(`a`.`table_id` = `ph`.`promo_history_id`)) left join `fee` `f` on(`a`.`table_id` = `f`.`fee_id`)) left join `merchant` `fm` on(`f`.`merchant_id` = `fm`.`merchant_id`)) left join `fee_history` `fh` on(`a`.`table_id` = `fh`.`fee_history_id`)) left join `fee` `ffh` on(`fh`.`fee_id` = `ffh`.`fee_id`)) left join `merchant` `fhm` on(`ffh`.`merchant_id` = `fhm`.`merchant_id`)) left join `transaction` `t` on(`a`.`table_id` = `t`.`transaction_id`)) left join `user` `u2` on(`a`.`table_id` = `u2`.`user_id`)) left join `report_history_coupled` `rhc` on(`a`.`table_id` = `rhc`.`coupled_report_id`)) left join `report_history_decoupled` `rhd` on(`a`.`table_id` = `rhd`.`decoupled_report_id`)) left join `report_history_gcash_head` `rhgh` on(`a`.`table_id` = `rhgh`.`gcash_report_id`)) left join `report_history_gcash_body` `rhgb` on(`a`.`table_id` = `rhgb`.`gcash_report_body_id`)) left join `report_history_gcash_body` `rhgb2` on(`rhgb2`.`gcash_report_id` = `rhgh`.`gcash_report_id`)) WHERE `a`.`table_name` in ('merchant','store','promo','promo_history','fee','fee_history','transaction','user','report_history_coupled','report_history_decoupled','report_history_gcash_head','report_history_gcash_body') ORDER BY `a`.`created_at` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `merchant_view`
--
DROP TABLE IF EXISTS `merchant_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `merchant_view`  AS SELECT `m`.`merchant_id` AS `merchant_id`, `m`.`merchant_name` AS `merchant_name`, CASE WHEN `m`.`merchant_partnership_type` is null THEN 'Unknown partnership type' ELSE `m`.`merchant_partnership_type` END AS `merchant_partnership_type`, CASE WHEN `m`.`legal_entity_name` is null THEN '-' ELSE `m`.`legal_entity_name` END AS `legal_entity_name`, CASE WHEN `m`.`business_address` is null THEN '-' ELSE `m`.`business_address` END AS `business_address`, CASE WHEN `m`.`email_address` is null THEN '-' ELSE `m`.`email_address` END AS `email_address`, CASE WHEN `m`.`sales` is null THEN '-' ELSE `m`.`sales` END AS `sales_id`, CASE WHEN `m`.`sales` is null THEN 'No assigned person' ELSE `u1`.`name` END AS `sales`, CASE WHEN `m`.`account_manager` is null THEN '-' ELSE `m`.`account_manager` END AS `account_manager_id`, CASE WHEN `m`.`account_manager` is null THEN 'No assigned person' ELSE `u2`.`name` END AS `account_manager`, `m`.`created_at` AS `created_at`, `m`.`updated_at` AS `updated_at` FROM ((`merchant` `m` left join `user` `u1` on(`u1`.`user_id` = `m`.`sales`)) left join `user` `u2` on(`u2`.`user_id` = `m`.`account_manager`)) ;

-- --------------------------------------------------------

--
-- Structure for view `transaction_summary_view`
--
DROP TABLE IF EXISTS `transaction_summary_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_summary_view`  AS WITH pg_fee_cte AS (SELECT `t`.`transaction_id` AS `transaction_id`, CASE WHEN `t`.`payment` in ('paymaya_credit_card','maya','maya_checkout','paymaya','gcash','gcash_miniapp') THEN (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = `t`.`payment` and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),case `t`.`payment` when 'paymaya_credit_card' then `f`.`paymaya_credit_card` when 'gcash' then `f`.`gcash` when 'gcash_miniapp' then `f`.`gcash_miniapp` when 'paymaya' then `f`.`paymaya` when 'maya_checkout' then `f`.`maya_checkout` when 'maya' then `f`.`maya` end)) WHEN `t`.`payment` is null OR `t`.`payment` = '' THEN 0 END AS `pg_fee_rate`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) AS `commission_type`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) AS `commission_rate` FROM (((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`))) SELECT substr(`t`.`transaction_id`,1,8) AS `Transaction ID`, concat('',date_format(`t`.`transaction_date`,'%M %d, %Y %h:%i%p'),'') AS `Formatted Transaction Date`, date_format(`t`.`transaction_date`,'%Y-%m-%d') AS `Transaction Date`, `m`.`merchant_id` AS `Merchant ID`, `m`.`merchant_name` AS `Merchant Name`, `s`.`store_id` AS `Store ID`, `s`.`store_name` AS `Store Name`, `t`.`customer_id` AS `Customer ID`, ifnull('-',`t`.`customer_name`) AS `Customer Name`, `p`.`promo_code` AS `Promo Code`, `p`.`voucher_type` AS `Voucher Type`, `p`.`promo_category` AS `Promo Category`, `p`.`promo_group` AS `Promo Group`, `p`.`promo_type` AS `Promo Type`, `t`.`gross_amount` AS `Gross Amount`, `t`.`discount` AS `Discount`, `t`.`amount_discounted` AS `Cart Amount`, CASE WHEN `t`.`payment` in ('paymaya_credit_card','maya','maya_checkout','paymaya','gcash','gcash_miniapp') THEN `t`.`payment` ELSE '-' END AS `Mode of Payment`, `t`.`bill_status` AS `Bill Status`, `t`.`comm_rate_base` AS `Comm Rate Base`, `pg_fee_cte`.`commission_type` AS `Commission Type`, concat(`pg_fee_cte`.`commission_rate`,'%') AS `Commission Rate`, round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100),2) AS `Commission Amount`, CASE WHEN `pg_fee_cte`.`commission_type` = 'Vat Exc' THEN round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100) * 1.12,2) WHEN `pg_fee_cte`.`commission_type` = 'Vat Inc' THEN round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100),2) END AS `Total Billing`, concat(`pg_fee_cte`.`pg_fee_rate`,'%') AS `PG Fee Rate`, round(`t`.`amount_discounted` * (`pg_fee_cte`.`pg_fee_rate` / 100),2) AS `PG Fee Amount`, `f`.`cwt_rate` AS `CWT Rate`, round(`t`.`amount_discounted` - case when `pg_fee_cte`.`commission_type` = 'Vat Exc' then round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100) * 1.12,2) when `pg_fee_cte`.`commission_type` = 'Vat Inc' then round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100),2) end - round(`t`.`amount_discounted` * (`pg_fee_cte`.`pg_fee_rate` / 100),2),2) AS `Amount to be Disbursed` FROM (((((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `promo` `p` on(`p`.`promo_code` = `t`.`promo_code`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`)) join `pg_fee_cte` on(`t`.`transaction_id` = `pg_fee_cte`.`transaction_id`)) ORDER BY `t`.`transaction_date` DESC;

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
  ADD PRIMARY KEY (`merchant_id`),
  ADD KEY `merchant_ibfk_1` (`sales`),
  ADD KEY `merchant_ibfk_2` (`account_manager`);

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
  ADD PRIMARY KEY (`decoupled_report_id`),
  ADD KEY `settlement_report_history_ibfk1` (`merchant_id`),
  ADD KEY `settlement_report_history_ibfk2` (`generated_by`),
  ADD KEY `settlement_report_history_ibfk3` (`store_id`);

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
-- Constraints for table `merchant`
--
ALTER TABLE `merchant`
  ADD CONSTRAINT `merchant_ibfk_1` FOREIGN KEY (`sales`) REFERENCES `user` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `merchant_ibfk_2` FOREIGN KEY (`account_manager`) REFERENCES `user` (`user_id`) ON DELETE SET NULL;

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
