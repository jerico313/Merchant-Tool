-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 13, 2024 at 05:35 PM
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
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out, commission_type)
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base A`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base A` * (`Commission Rate` / 100)
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
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
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
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base A`
                ELSE 0.00
            END) AS leadgen_commission_rate_base_pretrial,
            CONCAT(`Commission Rate`) AS commission_rate_pretrial,
            SUM(CASE
                WHEN `Bill Status` = ''PRE-TRIAL'' THEN `Comm Rate Base A` * (`Commission Rate` / 100)
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
            
            ROUND(SUM(`Cart Amount`)
                - SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)
                - SUM(`PG Fee Amount`)
                - CASE WHEN SUM(`Amount to be Disbursed`) <= 0.00 THEN 0.00 ELSE 10.00 END
                - ROUND((SUM(`Cart Amount`) - SUM(`PG Fee Amount`)) / 2 * 0.01, 2)
                + ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END)/ 1.12 * (`CWT Rate` / 100), 2)
                + ROUND(SUM(`PG Fee Amount`) / 1.12 * (`CWT Rate` / 100), 2),
            2) AS total_amount_paid_out,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
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
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * (`CWT Rate` / 100), 2) AS cwt_from_transaction_fees,
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
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
	        ROUND(SUM(CASE WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing` ELSE 0.00 END) / 1.12 * (`CWT Rate` / 100), 2) AS cwt_from_transaction_fees,
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
	    JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
        JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
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
            wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out, commission_type)
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
                    WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
            JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
            JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
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
                    WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
            JOIN `merchant` ON `Merchant ID` = merchant.`merchant_id`
            JOIN `fee` ON `Merchant ID` = fee.`merchant_id`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
         wtax_from_gross_sales, cwt_from_transaction_fees, cwt_from_pg_fees, total_amount_paid_out, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `decoupled_merchant_pretrial` (IN `merchant_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN

    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();

    SET @sql_insert = CONCAT('INSERT INTO report_history_decoupled 
        (decoupled_report_id, bill_status, merchant_id, merchant_business_name, merchant_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, 
         total_successful_orders, total_gross_sales, total_discount, total_outstanding_amount, 
         leadgen_commission_rate_base_pretrial, commission_rate_pretrial, total_pretrial, 
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
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
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
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
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
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
         leadgen_commission_rate_base_billable, commission_rate_billable, total_billable, total_commission_fees, commission_type)
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
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
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_billable,
            SUM(CASE
                WHEN `Bill Status` = ''BILLABLE'' THEN `Total Billing`
                ELSE 0.00
            END) AS total_commission_fees,
            fee.commission_type AS commission_type
        FROM `transaction_summary_view`
	    JOIN `store` ON `Store ID` = store.`store_id`
        JOIN `merchant` ON merchant.merchant_id = store.merchant_id
        JOIN `fee` ON fee.merchant_id = merchant.merchant_id
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
            AND `Bill Status` = ''BILLABLE''
        ');

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
            AND `Bill Status` = ''BILLABLE''
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
            AND `Bill Status` = ''BILLABLE''
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
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Item`');

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
            AND `Bill Status` = ''PRE-TRIAL''
        ');

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
            AND `Bill Status` = ''PRE-TRIAL''
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
            `Merchant ID` = "', merchant_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` = ''PRE-TRIAL''
        GROUP BY 
            `Item`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_store_all` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
     (gcash_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate, commission_amount, vat_amount, total_commission_fees)
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
         AND `Bill Status` != ''NOT BILLABLE''
     GROUP BY `Store ID`');

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
         AND `Bill Status` != ''NOT BILLABLE''
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
            `Store ID` = "', store_id, '"
            AND `Transaction Date` BETWEEN ''', start_date, ''' AND ''', end_date, '''
            AND `Bill Status` != ''NOT BILLABLE''
        GROUP BY 
            `Item`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_store_billable` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
    DECLARE v_uuid VARCHAR(36);
    SET v_uuid = UUID();
    
    SET @sql_insert = CONCAT('INSERT INTO report_history_gcash_head
     (gcash_report_id, bill_status, store_id, store_business_name, store_brand_name, business_address, settlement_period_start, settlement_period_end, settlement_date, settlement_number, settlement_period, total_amount, commission_rate, commission_amount, vat_amount, total_commission_fees)
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
         AND `Bill Status` = ''BILLABLE''
     GROUP BY `Store ID`');

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
         AND `Bill Status` = ''BILLABLE''
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
            AND `Bill Status` = ''BILLABLE''
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
            AND `Bill Status` = ''BILLABLE''
        GROUP BY 
            `Item`');

    PREPARE stmt_select1 FROM @sql_select1;
    EXECUTE stmt_select1;
    DEALLOCATE PREPARE stmt_select1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gcash_store_pretrial` (IN `store_id` VARCHAR(36), IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    
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
,`user_name` varchar(255)
,`table_name` varchar(50)
,`table_id` varchar(8)
,`column_name` varchar(255)
,`activity_type` enum('Add','Update','Delete','Login')
,`description` text
,`time_ago` varchar(78)
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
CREATE TRIGGER `fee_delete_log` AFTER DELETE ON `fee` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Fee record deleted\n',
  'merchant_id: ', IFNULL(OLD.merchant_id, 'N/A'), 
  '\n','paymaya_credit_card: ', IFNULL(OLD.paymaya_credit_card, 'N/A'), 
  '\n','paymaya: ', IFNULL(OLD.paymaya, 'N/A'), 
  '\n','gcash: ', IFNULL(OLD.gcash, 'N/A'),
  '\n','gcash_miniapp: ', IFNULL(OLD.gcash_miniapp, 'N/A'),
  '\n','maya_checkout: ', IFNULL(OLD.maya_checkout, 'N/A'),
  '\n','maya: ', IFNULL(OLD.maya, 'N/A'),
  '\n','lead_gen_commission: ', IFNULL(OLD.lead_gen_commission, 'N/A'),
  '\n','commission_type: ', IFNULL(OLD.commission_type, 'N/A'),
  '\n','cwt_rate: ', IFNULL(OLD.cwt_rate, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('fee', OLD.fee_id, 'Delete', description);
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
-- Triggers `fee_history`
--
DELIMITER $$
CREATE TRIGGER `fee_history_delete_log` AFTER DELETE ON `fee_history` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Fee history record deleted\n',
  'fee_id: ', IFNULL(OLD.fee_id, 'N/A'), 
  '\n','column_name: ', IFNULL(OLD.column_name, 'N/A'), 
  '\n','old_value: ', IFNULL(OLD.old_value, 'N/A'), 
  '\n','new_value: ', IFNULL(OLD.new_value, 'N/A'),
  '\n','changed_at: ', IFNULL(OLD.changed_at, 'N/A'),
  '\n','changed_by: ', IFNULL(OLD.changed_by, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('fee_history', OLD.fee_history_id, 'Delete', description);
END
$$
DELIMITER ;
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
-- Stand-in structure for view `gcash_transactions_view`
-- (See below for the actual view)
--
CREATE TABLE `gcash_transactions_view` (
`Transaction ID` varchar(8)
,`Formatted Transaction Date` varchar(81)
,`Transaction Date A` varchar(19)
,`Transaction Date` varchar(10)
,`Merchant ID` varchar(36)
,`Merchant Name` varchar(255)
,`Store ID` varchar(36)
,`Store Name` varchar(255)
,`Customer ID` varchar(14)
,`Customer Name` varchar(100)
,`Item` varchar(100)
,`Voucher Price` int(11)
,`Voucher Price A` varchar(17)
,`Total Merchant Sales` varchar(17)
,`Commission Rate` varchar(50)
,`Total Commission` varchar(416)
,`Bill Status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE')
);

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
  `sales` varchar(255) DEFAULT NULL,
  `account_manager` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
CREATE TRIGGER `merchant_delete_log` AFTER DELETE ON `merchant` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Merchant record deleted\n',
  'merchant_name: ', IFNULL(OLD.merchant_name, 'N/A'), 
  '\n','merchant_partnership_type: ', IFNULL(OLD.merchant_partnership_type, 'N/A'), 
  '\n','legal_entity_name: ', IFNULL(OLD.legal_entity_name, 'N/A'),
  '\n','business_address: ', IFNULL(OLD.business_address, 'N/A'),
  '\n','email_address: ', IFNULL(OLD.email_address, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('merchant', OLD.merchant_id, 'Delete', description);
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
,`sales` varchar(255)
,`account_manager` varchar(255)
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
  `promo_type` enum('BOGO','Bundle','Fixed discount','Free item','Fixed discount, Free item','Free item, Fixed discount','Percent discount','X for Y') NOT NULL,
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
-- Triggers `promo`
--
DELIMITER $$
CREATE TRIGGER `generate_promo_id` BEFORE INSERT ON `promo` FOR EACH ROW BEGIN
    SET NEW.promo_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `promo_delete_log` AFTER DELETE ON `promo` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Promo record deleted\n',
  '\n','promo_code: ', IFNULL(OLD.promo_code, 'N/A'), 
  '\n','merchant_id: ', IFNULL(OLD.merchant_id, 'N/A'),
  '\n','promo_amount: ', IFNULL(OLD.promo_amount, 'N/A'), 
  '\n','voucher_type: ', IFNULL(OLD.voucher_type, 'N/A'),
  '\n','promo_category: ', IFNULL(OLD.promo_category, 'N/A'), 
  '\n','promo_group: ', IFNULL(OLD.promo_group, 'N/A'),
  '\n','promo_type: ', IFNULL(OLD.promo_type, 'N/A'),
  '\n','promo_details: ', IFNULL(OLD.promo_details, 'N/A'),
  '\n','remarks: ', IFNULL(OLD.remarks, 'N/A'),
  '\n','bill_status: ', IFNULL(OLD.bill_status, 'N/A'),
  '\n','start_date: ', IFNULL(OLD.start_date, 'N/A'),
  '\n','end_date: ', IFNULL(OLD.end_date, 'N/A'),
  '\n','remarks2: ', IFNULL(OLD.remarks2, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('promo', OLD.promo_id, 'Delete', description);
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
  '\n','end_date: ', IFNULL(NEW.end_date, 'N/A'),
  '\n','remarks2: ', IFNULL(NEW.remarks2, 'N/A'));
  
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
  
  IF OLD.remarks2 != NEW.remarks2 THEN
    SET description = CONCAT(description, 'remarks2: ', OLD.remarks2, ' -> ', NEW.remarks2, '\n');
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
CREATE TRIGGER `promo_history_delete_log` AFTER DELETE ON `promo_history` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Promo history record deleted\n',
  'promo_code: ', IFNULL(OLD.promo_code, 'N/A'), 
  '\n','old_bill_status: ', IFNULL(OLD.old_bill_status, 'N/A'), 
  '\n','new_bill_status: ', IFNULL(OLD.new_bill_status, 'N/A'), 
  '\n','changed_at: ', IFNULL(OLD.changed_at, 'N/A'),
  '\n','changed_by: ', IFNULL(OLD.changed_by, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('promo_history', OLD.promo_history_id, 'Delete', description);
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
  `commission_type` enum('Vat Inc','Vat Exc') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `report_history_coupled`
--
DELIMITER $$
CREATE TRIGGER `report_history_coupled_delete_log` AFTER DELETE ON `report_history_coupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Coupled report history record deleted\n',
  'generated_by: ', IFNULL(OLD.generated_by, 'N/A'), 
  '\n','bill_status: ', IFNULL(OLD.bill_status, 'N/A'),
  '\n','merchant_id: ', IFNULL(OLD.merchant_id, 'N/A'), 
  '\n','merchant_business_name: ', IFNULL(OLD.merchant_business_name, 'N/A'), 
  '\n','merchant_brand_name: ', IFNULL(OLD.merchant_brand_name, 'N/A'),
  '\n','store_id: ', IFNULL(OLD.store_id, 'N/A'),
  '\n','store_business_name: ', IFNULL(OLD.store_business_name, 'N/A'), 
  '\n','store_brand_name: ', IFNULL(OLD.store_brand_name, 'N/A'),
  '\n','business_address: ', IFNULL(OLD.business_address, 'N/A'),
  '\n','settlement_period_start: ', IFNULL(OLD.settlement_period_start, 'N/A'),
  '\n','settlement_period_end: ', IFNULL(OLD.settlement_period_end, 'N/A'),
  '\n','settlement_number: ', IFNULL(OLD.settlement_number, 'N/A'),
                          
  '\n','total_successful_orders: ', IFNULL(OLD.total_successful_orders, 'N/A'),
  '\n','total_gross_sales: ', IFNULL(OLD.total_gross_sales, 'N/A'),
  '\n','total_discount: ', IFNULL(OLD.total_discount, 'N/A'),
  '\n','total_outstanding_amount_1: ', IFNULL(OLD.total_outstanding_amount_1, 'N/A'),
                           
  '\n','leadgen_commission_rate_base_pretrial: ', IFNULL(OLD.leadgen_commission_rate_base_pretrial, 'N/A'),
  '\n','commission_rate_pretrial: ', IFNULL(OLD.commission_rate_pretrial, 'N/A'),
  '\n','total_pretrial: ', IFNULL(OLD.total_pretrial, 'N/A'),
                           
  '\n','leadgen_commission_rate_base_billable: ', IFNULL(OLD.leadgen_commission_rate_base_billable, 'N/A'),
  '\n','commission_rate_billable: ', IFNULL(OLD.commission_rate_billable, 'N/A'),
  '\n','total_billable: ', IFNULL(OLD.total_billable, 'N/A'),
  '\n','total_commission_fees_1: ', IFNULL(OLD.total_commission_fees_1, 'N/A'),

  '\n','card_payment_pg_fee: ', IFNULL(OLD.card_payment_pg_fee, 'N/A'),
  '\n','paymaya_pg_fee: ', IFNULL(OLD.paymaya_pg_fee, 'N/A'),
  '\n','gcash_miniapp_pg_fee: ', IFNULL(OLD.gcash_miniapp_pg_fee, 'N/A'),
  '\n','gcash_pg_fee: ', IFNULL(OLD.gcash_pg_fee, 'N/A'),
  '\n','total_payment_gateway_fees_1: ', IFNULL(OLD.total_payment_gateway_fees_1, 'N/A'),

  '\n','total_outstanding_amount_2: ', IFNULL(OLD.total_outstanding_amount_2, 'N/A'),
  '\n','total_commission_fees_2: ', IFNULL(OLD.total_commission_fees_2, 'N/A'),
  '\n','total_payment_gateway_fees_2: ', IFNULL(OLD.total_payment_gateway_fees_2, 'N/A'),
  '\n','bank_fees: ', IFNULL(OLD.bank_fees, 'N/A'),

  '\n','wtax_from_gross_sales: ', IFNULL(OLD.wtax_from_gross_sales, 'N/A'),
  '\n','cwt_from_transaction_fees: ', IFNULL(OLD.cwt_from_transaction_fees, 'N/A'),
  '\n','cwt_from_pg_fees: ', IFNULL(OLD.cwt_from_pg_fees, 'N/A'),
  '\n','total_amount_paid_out: ', IFNULL(OLD.total_amount_paid_out, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_coupled', OLD.coupled_report_id, 'Delete', description);
END
$$
DELIMITER ;
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
  `commission_type` enum('Vat Inc','Vat Exc') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `report_history_decoupled`
--
DELIMITER $$
CREATE TRIGGER `report_history_decoupled_delete_log` AFTER DELETE ON `report_history_decoupled` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Decoupled report history record deleted\n',
  'generated_by: ', IFNULL(OLD.generated_by, 'N/A'), 
  '\n','bill_status: ', IFNULL(OLD.bill_status, 'N/A'),
  '\n','merchant_id: ', IFNULL(OLD.merchant_id, 'N/A'), 
  '\n','merchant_business_name: ', IFNULL(OLD.merchant_business_name, 'N/A'), 
  '\n','merchant_brand_name: ', IFNULL(OLD.merchant_brand_name, 'N/A'),
  '\n','store_id: ', IFNULL(OLD.store_id, 'N/A'),
  '\n','store_business_name: ', IFNULL(OLD.store_business_name, 'N/A'), 
  '\n','store_brand_name: ', IFNULL(OLD.store_brand_name, 'N/A'),
  '\n','business_address: ', IFNULL(OLD.business_address, 'N/A'),
  '\n','settlement_period_start: ', IFNULL(OLD.settlement_period_start, 'N/A'),
  '\n','settlement_period_end: ', IFNULL(OLD.settlement_period_end, 'N/A'),
  '\n','settlement_number: ', IFNULL(OLD.settlement_number, 'N/A'),
                          
  '\n','total_successful_orders: ', IFNULL(OLD.total_successful_orders, 'N/A'),
  '\n','total_gross_sales: ', IFNULL(OLD.total_gross_sales, 'N/A'),
  '\n','total_discount: ', IFNULL(OLD.total_discount, 'N/A'),
  '\n','total_outstanding_amount: ', IFNULL(OLD.total_outstanding_amount, 'N/A'),
                           
  '\n','leadgen_commission_rate_base_pretrial: ', IFNULL(OLD.leadgen_commission_rate_base_pretrial, 'N/A'),
  '\n','commission_rate_pretrial: ', IFNULL(OLD.commission_rate_pretrial, 'N/A'),
  '\n','total_pretrial: ', IFNULL(OLD.total_pretrial, 'N/A'),
                           
  '\n','leadgen_commission_rate_base_billable: ', IFNULL(OLD.leadgen_commission_rate_base_billable, 'N/A'),
  '\n','commission_rate_billable: ', IFNULL(OLD.commission_rate_billable, 'N/A'),
  '\n','total_billable: ', IFNULL(OLD.total_billable, 'N/A'),
                           
  '\n','total_commission_fees: ', IFNULL(OLD.total_commission_fees, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_decoupled', OLD.decoupled_report_id, 'Delete', description);
END
$$
DELIMITER ;
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
  `voucher_value` decimal(10,2) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
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
CREATE TRIGGER `report_history_gcash_body_delete_log` AFTER DELETE ON `report_history_gcash_body` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Gcash report history body record deleted\n',
  'gcash_report_id: ', IFNULL(OLD.gcash_report_id, 'N/A'), 
  '\n','item: ', IFNULL(OLD.item, 'N/A'), 
  '\n','quantity_redeemed: ', IFNULL(OLD.quantity_redeemed, 'N/A'), 
  '\n','voucher_value: ', IFNULL(OLD.voucher_value, 'N/A'), 
  '\n','amount: ', IFNULL(OLD.amount, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_body', OLD.gcash_report_body_id, 'Delete', description);
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
  '\n','voucher_value: ', IFNULL(NEW.voucher_value, 'N/A'), 
  '\n','amount: ', IFNULL(NEW.amount, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_body', NEW.gcash_report_body_id, 'Add', description);
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

  IF OLD.voucher_value != NEW.voucher_value THEN
    SET description = CONCAT(description, 'voucher_value: ', OLD.voucher_value, ' -> ', NEW.voucher_value, '\n');
  END IF;

  IF OLD.amount != NEW.amount THEN
    SET description = CONCAT(description, 'amount: ', OLD.amount, ' -> ', NEW.amount, '\n');
  END IF;
  
  -- Remove the trailing '\n' from the description
  SET description = LEFT(description, LENGTH(description) - 1);
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_body', NEW.gcash_report_body_id, 'Update', description);
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
CREATE TRIGGER `report_history_gcash_head_delete_log` AFTER DELETE ON `report_history_gcash_head` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Gcash report history head record deleted\n',
  'generated_by: ', IFNULL(OLD.generated_by, 'N/A'), 
  '\n','bill_status: ', IFNULL(OLD.bill_status, 'N/A'),
  '\n','merchant_id: ', IFNULL(OLD.merchant_id, 'N/A'), 
  '\n','merchant_business_name: ', IFNULL(OLD.merchant_business_name, 'N/A'), 
  '\n','merchant_brand_name: ', IFNULL(OLD.merchant_brand_name, 'N/A'),
  '\n','store_id: ', IFNULL(OLD.store_id, 'N/A'),
  '\n','store_business_name: ', IFNULL(OLD.store_business_name, 'N/A'), 
  '\n','store_brand_name: ', IFNULL(OLD.store_brand_name, 'N/A'),
  '\n','business_address: ', IFNULL(OLD.business_address, 'N/A'),
  '\n','settlement_period_start: ', IFNULL(OLD.settlement_period_start, 'N/A'),
  '\n','settlement_period_end: ', IFNULL(OLD.settlement_period_end, 'N/A'),
  '\n','settlement_date: ', IFNULL(OLD.settlement_date, 'N/A'),
  '\n','settlement_number: ', IFNULL(OLD.settlement_number, 'N/A'),
  '\n','settlement_period: ', IFNULL(OLD.settlement_period, 'N/A'),
  '\n','total_amount: ', IFNULL(OLD.total_amount, 'N/A'),
  '\n','commission_rate: ', IFNULL(OLD.commission_rate, 'N/A'),
  '\n','vat_amount: ', IFNULL(OLD.vat_amount, 'N/A'),
  '\n','total_commission_fees: ', IFNULL(OLD.total_commission_fees, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('report_history_gcash_head', OLD.gcash_report_id, 'Delete', description);
END
$$
DELIMITER ;
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
  `store_name` varchar(255) NOT NULL,
  `legal_entity_name` varchar(255) DEFAULT NULL,
  `store_address` text DEFAULT NULL,
  `email_address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
CREATE TRIGGER `store_delete_log` AFTER DELETE ON `store` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Store record deleted\n',
  'merchant_id: ', IFNULL(OLD.merchant_id, 'N/A'), 
  '\n','store_name: ', IFNULL(OLD.store_name, 'N/A'), 
  '\n','legal_entity_name: ', IFNULL(OLD.legal_entity_name, 'N/A'), 
  '\n','store_address: ', IFNULL(OLD.store_address, 'N/A'),
  '\n','email_address: ', IFNULL(OLD.email_address, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('store', OLD.store_id, 'Delete', description);
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
  '\n','store_address: ', IFNULL(NEW.store_address, 'N/A'),
  '\n','email_address: ', IFNULL(NEW.email_address, 'N/A'));
                            
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
  
  IF OLD.email_address != NEW.email_address THEN
    SET description = CONCAT(description, 'email_address: ', OLD.email_address, ' -> ', NEW.email_address, '\n');
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
-- Stand-in structure for view `store_view`
-- (See below for the actual view)
--
CREATE TABLE `store_view` (
`store_id` varchar(36)
,`store_name` varchar(255)
,`legal_entity_name` varchar(255)
,`store_address` mediumtext
,`email_address` mediumtext
,`merchant_id` varchar(36)
,`merchant_name` varchar(255)
,`created_at` timestamp
,`updated_at` timestamp
);

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
  `amount_paid` decimal(10,2) NOT NULL,
  `payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya') DEFAULT NULL,
  `comm_rate_base` decimal(10,2) NOT NULL,
  `bill_status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
CREATE TRIGGER `transaction_delete_log` AFTER DELETE ON `transaction` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('Transaction record deleted\n',
  'store_id: ', IFNULL(OLD.store_id, 'N/A'), 
  '\n','promo_code: ', IFNULL(OLD.promo_code, 'N/A'), 
  '\n','customer_id: ', IFNULL(OLD.customer_id, 'N/A'), 
  '\n','transaction_date: ', IFNULL(OLD.transaction_date, 'N/A'),
  '\n','gross_amount: ', IFNULL(OLD.gross_amount, 'N/A'), 
  '\n','discount: ', IFNULL(OLD.discount, 'N/A'), 
  '\n','amount_discounted: ', IFNULL(OLD.amount_discounted, 'N/A'), 
  '\n','payment: ', IFNULL(OLD.payment, 'N/A'), 
  '\n','bill_status: ', IFNULL(OLD.bill_status, 'N/A'));
                            
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('transaction', OLD.transaction_id, 'Delete', description);
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
,`Transaction Date A` varchar(19)
,`Transaction Date` varchar(10)
,`Merchant ID` varchar(36)
,`Merchant Name` varchar(255)
,`Store ID` varchar(36)
,`Store Name` varchar(255)
,`Customer ID` varchar(14)
,`Customer Name` varchar(100)
,`Promo Code` varchar(100)
,`Voucher Type` enum('Coupled','Decoupled')
,`Promo Category` enum('Grab & Go','Casual Dining')
,`Promo Group` enum('Booky','Gcash','Unionbank','Gcash/Booky','UB/Booky')
,`Promo Type` enum('BOGO','Bundle','Fixed discount','Free item','Fixed discount, Free item','Free item, Fixed discount','Percent discount','X for Y')
,`Gross Amount` decimal(10,2)
,`Discount` decimal(10,2)
,`Amount Discounted` decimal(10,2)
,`Cart Amount` decimal(10,2)
,`Mode of Payment` varchar(19)
,`Bill Status` enum('PRE-TRIAL','BILLABLE','NOT BILLABLE')
,`Comm Rate Base` decimal(10,2)
,`Comm Rate Base A` decimal(10,2)
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
  `email_address` varchar(255) NOT NULL,
  `password` varchar(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` enum('Admin','User') NOT NULL DEFAULT 'User',
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `verification_code` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `email_address`, `password`, `name`, `type`, `status`, `verification_code`, `created_at`, `updated_at`) VALUES
('031c090d-3826-11ef-9d23-0a002700000d', 'rominna@booky.ph', '$2y$10$Q49RiBWN5YY4ifaslsE8he7XHED6Jr0vyQ7s5Izij4bg57oneXY9W', 'Rominna Angeline R. Raymundo', 'User', 'Active', NULL, '2024-07-02 03:48:58', '2024-07-04 01:17:51'),
('09d8d971-342e-11ef-b7ae-0a002700000d', 'admin@booky.ph', '$2y$10$QPrvim.Z8xAZjI2TOLASWeXwuaxjn4dzob7tLlB90Vp9PUpa8XyE2', 'Admin', 'Admin', 'Active', NULL, '2024-06-27 02:36:21', '2024-07-04 01:17:59'),
('acea8342-388e-11ef-b4b1-0a002700000d', 'cookie@booky.ph', '$2y$10$dRffZ66tPS8hHDmkIWssSOOlk21L1/H3g1lOz6J8uxldv.BM.5rci', 'Cookie', 'Admin', 'Active', NULL, '2024-07-04 01:21:20', '2024-08-01 01:35:48'),
('b1a44bae-3825-11ef-9d23-0a002700000d', 'ben@booky.ph', '$2y$10$nNJgZho7u3EoVduIQvNqquhWT/mrR2j6foaVuAHx9QpOcrdxG14ce', 'Ben Wintle', 'User', 'Active', NULL, '2024-07-02 03:46:41', '2024-07-04 01:18:04');

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
CREATE TRIGGER `user_delete_log` AFTER DELETE ON `user` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('User record deleted\n',
  'email_address: ', IFNULL(OLD.email_address, 'N/A'), 
  '\n','password: ', IFNULL('password', 'N/A'), 
  '\n','name: ', IFNULL(OLD.name, 'N/A'), 
  '\n','type: ', IFNULL(OLD.type, 'N/A'),
  '\n','status: ', IFNULL(OLD.status, 'N/A'),
  '\n','verification_code: ', IFNULL(OLD.verification_code, 'N/A'));
  
  INSERT INTO activity_history (table_name, table_id, activity_type, description)
  VALUES ('user', OLD.user_id, 'Delete', description);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `user_insert_log` AFTER INSERT ON `user` FOR EACH ROW BEGIN
  DECLARE description TEXT;
  SET description = CONCAT('User record added\n',
  'email_address: ', IFNULL(NEW.email_address, 'N/A'), 
  '\n','password: ', IFNULL('password', 'N/A'), 
  '\n','name: ', IFNULL(NEW.name, 'N/A'), 
  '\n','type: ', IFNULL(NEW.type, 'N/A'),
  '\n','status: ', IFNULL(NEW.status, 'N/A'),
  '\n','verification_code: ', IFNULL(NEW.verification_code, 'N/A'));
  
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
    SET description = CONCAT(description, 'password updated' '\n');
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
  
  IF OLD.verification_code != NEW.verification_code THEN
    SET description = CONCAT(description, 'verification_code: ', OLD.verification_code, ' -> ', NEW.verification_code, '\n');
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

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `activity_history_view`  AS SELECT substr(`a`.`activity_id`,1,8) AS `activity_history_id`, substr(coalesce(`a`.`user_id`,'xxxxxxxx'),1,8) AS `user_id`, coalesce(`u`.`name`,'Unknown user') AS `user_name`, `a`.`table_name` AS `table_name`, substr(coalesce(case when `a`.`table_name` = 'merchant' then `m`.`merchant_id` when `a`.`table_name` = 'store' then `s`.`store_id` when `a`.`table_name` = 'promo' then `p`.`promo_id` when `a`.`table_name` = 'promo_history' then `ph`.`promo_history_id` when `a`.`table_name` = 'fee' then `f`.`fee_id` when `a`.`table_name` = 'fee_history' then `fh`.`fee_history_id` when `a`.`table_name` = 'transaction' then `t`.`transaction_id` when `a`.`table_name` = 'report_history_coupled' then `rhc`.`coupled_report_id` when `a`.`table_name` = 'report_history_decoupled' then `rhd`.`decoupled_report_id` when `a`.`table_name` = 'report_history_gcash_head' then `rhgh`.`gcash_report_id` when `a`.`table_name` = 'report_history_gcash_body' then `rhgb`.`gcash_report_body_id` else `a`.`table_id` end,`a`.`table_id`),1,8) AS `table_id`, coalesce(case when `a`.`table_name` = 'merchant' then `m`.`merchant_name` when `a`.`table_name` = 'store' then `s`.`store_name` when `a`.`table_name` = 'promo' then `p`.`promo_code` when `a`.`table_name` = 'promo_history' then `ph`.`promo_code` when `a`.`table_name` = 'fee' then `fm`.`merchant_name` when `a`.`table_name` = 'fee_history' then `fhm`.`merchant_name` when `a`.`table_name` = 'transaction' then `t`.`customer_id` when `a`.`table_name` = 'report_history_coupled' then `rhc`.`settlement_number` when `a`.`table_name` = 'report_history_decoupled' then `rhd`.`settlement_number` when `a`.`table_name` = 'report_history_gcash_head' then `rhgh`.`settlement_number` when `a`.`table_name` = 'report_history_gcash_body' then `rhgh`.`settlement_number` else NULL end,'Deleted') AS `column_name`, `a`.`activity_type` AS `activity_type`, `a`.`description` AS `description`, CASE WHEN timestampdiff(SECOND,`a`.`created_at`,current_timestamp()) < 60 THEN concat(timestampdiff(SECOND,`a`.`created_at`,current_timestamp()),' second',if(timestampdiff(SECOND,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago') WHEN timestampdiff(MINUTE,`a`.`created_at`,current_timestamp()) < 60 THEN concat(timestampdiff(MINUTE,`a`.`created_at`,current_timestamp()),' minute',if(timestampdiff(MINUTE,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago') WHEN timestampdiff(HOUR,`a`.`created_at`,current_timestamp()) < 24 THEN concat(timestampdiff(HOUR,`a`.`created_at`,current_timestamp()),' hour',if(timestampdiff(HOUR,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago') WHEN timestampdiff(DAY,`a`.`created_at`,current_timestamp()) < 7 THEN concat(timestampdiff(DAY,`a`.`created_at`,current_timestamp()),' day',if(timestampdiff(DAY,`a`.`created_at`,current_timestamp()) = 1,'','s'),' ago at ',date_format(`a`.`created_at`,'%l:%i%p')) ELSE date_format(`a`.`created_at`,'%M %d at %l:%i%p') END AS `time_ago`, `a`.`created_at` AS `created_at`, `a`.`updated_at` AS `updated_at` FROM ((((((((((((((((`activity_history` `a` left join `user` `u` on(`u`.`user_id` = `a`.`user_id`)) left join `merchant` `m` on(`a`.`table_id` = `m`.`merchant_id`)) left join `store` `s` on(`a`.`table_id` = `s`.`store_id`)) left join `promo` `p` on(`a`.`table_id` = `p`.`promo_id`)) left join `promo_history` `ph` on(`a`.`table_id` = `ph`.`promo_history_id`)) left join `fee` `f` on(`a`.`table_id` = `f`.`fee_id`)) left join `merchant` `fm` on(`f`.`merchant_id` = `fm`.`merchant_id`)) left join `fee_history` `fh` on(`a`.`table_id` = `fh`.`fee_history_id`)) left join `fee` `ffh` on(`fh`.`fee_id` = `ffh`.`fee_id`)) left join `merchant` `fhm` on(`ffh`.`merchant_id` = `fhm`.`merchant_id`)) left join `transaction` `t` on(`a`.`table_id` = `t`.`transaction_id`)) left join `report_history_coupled` `rhc` on(`a`.`table_id` = `rhc`.`coupled_report_id`)) left join `report_history_decoupled` `rhd` on(`a`.`table_id` = `rhd`.`decoupled_report_id`)) left join `report_history_gcash_head` `rhgh` on(`a`.`table_id` = `rhgh`.`gcash_report_id`)) left join `report_history_gcash_body` `rhgb` on(`a`.`table_id` = `rhgb`.`gcash_report_body_id`)) left join `report_history_gcash_body` `rhgb2` on(`rhgb2`.`gcash_report_body_id` = `rhgh`.`gcash_report_id`)) WHERE `a`.`table_name` in ('merchant','store','promo','promo_history','fee','fee_history','transaction','report_history_coupled','report_history_decoupled','report_history_gcash_head','report_history_gcash_body') ORDER BY `a`.`created_at` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `gcash_transactions_view`
--
DROP TABLE IF EXISTS `gcash_transactions_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `gcash_transactions_view`  AS WITH pg_fee_cte AS (SELECT `t`.`transaction_id` AS `transaction_id`, CASE WHEN `t`.`payment` in ('paymaya_credit_card','maya','maya_checkout','paymaya','gcash','gcash_miniapp') THEN (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = `t`.`payment` and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),case `t`.`payment` when 'paymaya_credit_card' then `f`.`paymaya_credit_card` when 'gcash' then `f`.`gcash` when 'gcash_miniapp' then `f`.`gcash_miniapp` when 'paymaya' then `f`.`paymaya` when 'maya_checkout' then `f`.`maya_checkout` when 'maya' then `f`.`maya` end)) WHEN `t`.`payment` is null OR `t`.`payment` = '' THEN 0 END AS `pg_fee_rate`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) AS `commission_type`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) AS `commission_rate` FROM (((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`))) SELECT substr(`t`.`transaction_id`,1,8) AS `Transaction ID`, concat('',date_format(`t`.`transaction_date`,'%M %d, %Y %h:%i%p'),'') AS `Formatted Transaction Date`, date_format(`t`.`transaction_date`,'%Y-%m-%d %T') AS `Transaction Date A`, date_format(`t`.`transaction_date`,'%Y-%m-%d') AS `Transaction Date`, `m`.`merchant_id` AS `Merchant ID`, `m`.`merchant_name` AS `Merchant Name`, `s`.`store_id` AS `Store ID`, `s`.`store_name` AS `Store Name`, `t`.`customer_id` AS `Customer ID`, CASE WHEN `t`.`customer_name` is null THEN '-' ELSE `t`.`customer_name` END AS `Customer Name`, `p`.`promo_code` AS `Item`, `p`.`promo_amount` AS `Voucher Price`, format(`p`.`promo_amount`,2) AS `Voucher Price A`, format(`p`.`promo_amount`,2) AS `Total Merchant Sales`, `pg_fee_cte`.`commission_rate` AS `Commission Rate`, format(case when `pg_fee_cte`.`commission_type` = 'Vat Exc' then round(`p`.`promo_amount` * (`pg_fee_cte`.`commission_rate` / 100) * 1.12,2) when `pg_fee_cte`.`commission_type` = 'Vat Inc' then round(`p`.`promo_amount` * (`pg_fee_cte`.`commission_rate` / 100),2) end,2) AS `Total Commission`, `t`.`bill_status` AS `Bill Status` FROM (((((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `promo` `p` on(`p`.`promo_code` = `t`.`promo_code`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`)) join `pg_fee_cte` on(`t`.`transaction_id` = `pg_fee_cte`.`transaction_id`)) WHERE `p`.`promo_group` = 'Gcash' ORDER BY `t`.`transaction_date` DESC;

-- --------------------------------------------------------

--
-- Structure for view `merchant_view`
--
DROP TABLE IF EXISTS `merchant_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `merchant_view`  AS SELECT `m`.`merchant_id` AS `merchant_id`, `m`.`merchant_name` AS `merchant_name`, CASE WHEN `m`.`merchant_partnership_type` is null THEN 'Unknown partnership type' ELSE `m`.`merchant_partnership_type` END AS `merchant_partnership_type`, CASE WHEN `m`.`legal_entity_name` is null THEN '-' ELSE `m`.`legal_entity_name` END AS `legal_entity_name`, CASE WHEN `m`.`business_address` is null THEN '-' ELSE `m`.`business_address` END AS `business_address`, CASE WHEN `m`.`email_address` is null THEN '-' ELSE `m`.`email_address` END AS `email_address`, CASE WHEN `m`.`sales` is null THEN 'No assigned person' ELSE `m`.`sales` END AS `sales`, CASE WHEN `m`.`account_manager` is null THEN 'No assigned person' ELSE `m`.`account_manager` END AS `account_manager`, `m`.`created_at` AS `created_at`, `m`.`updated_at` AS `updated_at` FROM ((`merchant` `m` left join `user` `u1` on(`u1`.`user_id` = `m`.`sales`)) left join `user` `u2` on(`u2`.`user_id` = `m`.`account_manager`)) ;

-- --------------------------------------------------------

--
-- Structure for view `store_view`
--
DROP TABLE IF EXISTS `store_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `store_view`  AS SELECT `s`.`store_id` AS `store_id`, `s`.`store_name` AS `store_name`, CASE WHEN `s`.`legal_entity_name` is null THEN '-' ELSE `s`.`legal_entity_name` END AS `legal_entity_name`, CASE WHEN `s`.`store_address` is null THEN '-' ELSE `s`.`store_address` END AS `store_address`, CASE WHEN `s`.`email_address` is null THEN '-' ELSE `s`.`email_address` END AS `email_address`, `m`.`merchant_id` AS `merchant_id`, `m`.`merchant_name` AS `merchant_name`, `s`.`created_at` AS `created_at`, `s`.`updated_at` AS `updated_at` FROM (`store` `s` join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `transaction_summary_view`
--
DROP TABLE IF EXISTS `transaction_summary_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_summary_view`  AS WITH pg_fee_cte AS (SELECT `t`.`transaction_id` AS `transaction_id`, CASE WHEN `t`.`payment` in ('paymaya_credit_card','maya','maya_checkout','paymaya','gcash','gcash_miniapp') THEN (select coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = `t`.`payment` and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),case `t`.`payment` when 'paymaya_credit_card' then `f`.`paymaya_credit_card` when 'gcash' then `f`.`gcash` when 'gcash_miniapp' then `f`.`gcash_miniapp` when 'paymaya' then `f`.`paymaya` when 'maya_checkout' then `f`.`maya_checkout` when 'maya' then `f`.`maya` end)) WHEN `t`.`payment` is null OR `t`.`payment` = '' THEN 0 END AS `pg_fee_rate`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'commission_type' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`commission_type`) AS `commission_type`, coalesce((select `fh`.`old_value` from `fee_history` `fh` where `fh`.`fee_id` = `f`.`fee_id` and `fh`.`column_name` = 'lead_gen_commission' and `fh`.`changed_at` >= `t`.`transaction_date` order by `fh`.`changed_at` desc limit 1),`f`.`lead_gen_commission`) AS `commission_rate` FROM (((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`))) SELECT substr(`t`.`transaction_id`,1,8) AS `Transaction ID`, concat('',date_format(`t`.`transaction_date`,'%M %d, %Y %h:%i%p'),'') AS `Formatted Transaction Date`, date_format(`t`.`transaction_date`,'%Y-%m-%d %T') AS `Transaction Date A`, date_format(`t`.`transaction_date`,'%Y-%m-%d') AS `Transaction Date`, `m`.`merchant_id` AS `Merchant ID`, `m`.`merchant_name` AS `Merchant Name`, `s`.`store_id` AS `Store ID`, `s`.`store_name` AS `Store Name`, `t`.`customer_id` AS `Customer ID`, CASE WHEN `t`.`customer_name` is null THEN '-' ELSE `t`.`customer_name` END AS `Customer Name`, `p`.`promo_code` AS `Promo Code`, `p`.`voucher_type` AS `Voucher Type`, `p`.`promo_category` AS `Promo Category`, `p`.`promo_group` AS `Promo Group`, `p`.`promo_type` AS `Promo Type`, CASE WHEN `t`.`payment` is null THEN 0.00 WHEN `t`.`payment` = 'gcash_miniapp' THEN 0.00 WHEN `t`.`amount_paid` = 0.00 THEN 0.00 ELSE `t`.`gross_amount` END AS `Gross Amount`, CASE WHEN `t`.`payment` is null THEN 0.00 WHEN `t`.`payment` = 'gcash_miniapp' THEN 0.00 WHEN `t`.`amount_paid` = 0.00 THEN 0.00 ELSE `t`.`discount` END AS `Discount`, CASE WHEN `t`.`payment` is null THEN 0.00 WHEN `t`.`payment` = 'gcash_miniapp' THEN 0.00 WHEN `t`.`amount_paid` = 0.00 THEN 0.00 ELSE `t`.`amount_discounted` END AS `Amount Discounted`, `t`.`amount_paid` AS `Cart Amount`, CASE WHEN `t`.`payment` in ('paymaya_credit_card','maya','maya_checkout') THEN 'Card Payment' WHEN `t`.`payment` in ('paymaya','gcash','gcash_miniapp') THEN `t`.`payment` ELSE '-' END AS `Mode of Payment`, `t`.`bill_status` AS `Bill Status`, `t`.`comm_rate_base` AS `Comm Rate Base`, `t`.`comm_rate_base` AS `Comm Rate Base A`, `pg_fee_cte`.`commission_type` AS `Commission Type`, concat(`pg_fee_cte`.`commission_rate`,'%') AS `Commission Rate`, round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100),2) AS `Commission Amount`, CASE WHEN `pg_fee_cte`.`commission_type` = 'Vat Exc' THEN round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100) * 1.12,2) WHEN `pg_fee_cte`.`commission_type` = 'Vat Inc' THEN round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100),2) END AS `Total Billing`, concat(`pg_fee_cte`.`pg_fee_rate`,'%') AS `PG Fee Rate`, round(`t`.`amount_paid` * (`pg_fee_cte`.`pg_fee_rate` / 100),2) AS `PG Fee Amount`, `f`.`cwt_rate` AS `CWT Rate`, round(`t`.`amount_paid` - case when `pg_fee_cte`.`commission_type` = 'Vat Exc' then round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100) * 1.12,2) when `pg_fee_cte`.`commission_type` = 'Vat Inc' then round(`t`.`comm_rate_base` * (`pg_fee_cte`.`commission_rate` / 100),2) end - round(`t`.`amount_paid` * (`pg_fee_cte`.`pg_fee_rate` / 100),2),2) AS `Amount to be Disbursed` FROM (((((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `promo` `p` on(`p`.`promo_code` = `t`.`promo_code`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`)) join `pg_fee_cte` on(`t`.`transaction_id` = `pg_fee_cte`.`transaction_id`)) ORDER BY `t`.`transaction_date` DESC;

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
