DROP VIEW IF EXISTS transaction_summary_view;

CREATE VIEW transaction_summary_view AS
WITH pg_fee_cte AS (
    SELECT t.transaction_id,
    ROW_NUMBER() OVER (PARTITION BY t.transaction_id ORDER BY f.effective_date DESC) AS row_num,

        CASE
            WHEN `t`.`payment` IN (
                'paymaya_credit_card',
                'maya',
                'maya_checkout',
                'paymaya',
                'gcash',
                'gcash_miniapp'
            ) THEN
                (SELECT COALESCE(
                    CASE
                        WHEN `t`.`payment` = 'paymaya_credit_card' THEN `f`.`paymaya_credit_card`
                        WHEN `t`.`payment` = 'gcash' THEN `f`.`gcash`
                        WHEN `t`.`payment` = 'gcash_miniapp' THEN `f`.`gcash_miniapp`
                        WHEN `t`.`payment` = 'paymaya' THEN `f`.`paymaya`
                        WHEN `t`.`payment` = 'maya_checkout' THEN `f`.`maya_checkout`
                        WHEN `t`.`payment` = 'maya' THEN `f`.`maya`
                    END, 0)
                FROM `leadgen_db`.`fee` `f`
                WHERE `f`.`merchant_id` = `m`.`merchant_id`
                AND `f`.`effective_date` <= `t`.`transaction_date`
                ORDER BY `f`.`effective_date` DESC
                LIMIT 1)
            WHEN `t`.`payment` IS NULL OR `t`.`payment` = '' THEN 0
        END AS pg_fee_rate,

        COALESCE(
            (SELECT `f`.`commission_type`
            FROM `leadgen_db`.`fee` `f`
            WHERE `f`.`merchant_id` = `m`.`merchant_id`
            AND `f`.`effective_date` <= `t`.`transaction_date`
            ORDER BY `f`.`effective_date` DESC
            LIMIT 1), 
            0
        ) AS commission_type,

        COALESCE(
            (SELECT  `f`.`lead_gen_commission`
            FROM `leadgen_db`.`fee` `f`
            WHERE `f`.`merchant_id` = `m`.`merchant_id`
            AND `f`.`effective_date` <= `t`.`transaction_date`
            ORDER BY `f`.`effective_date` DESC
            LIMIT 1), 
            0
        ) AS commission_rate,
        
        COALESCE(
            (SELECT `cwt`.`cwt_rate`
            FROM `leadgen_db`.`cwt_rate` `cwt`
            WHERE `cwt`.`store_id` = `s`.`store_id`
            AND `cwt`.`effective_date` <= `t`.`transaction_date`
            ORDER BY `cwt`.`effective_date` DESC 
            LIMIT 1), 
            0
        ) AS cwt_rate
    FROM `leadgen_db`.`transaction` `t`
        JOIN `leadgen_db`.`store` `s` ON (`t`.`store_id` = `s`.`store_id`)
        JOIN `leadgen_db`.`merchant` `m` ON (`m`.`merchant_id` = `s`.`merchant_id`)
        LEFT JOIN `leadgen_db`.`fee` `f` ON (`f`.`merchant_id` = `m`.`merchant_id`)
)

SELECT DISTINCT
    `t`.`transaction_id` AS `Transaction ID`,
    CONCAT('',DATE_FORMAT(`t`.`transaction_date`, '%M %d, %Y %h:%i%p'),'') AS `Formatted Transaction Date`,
    DATE_FORMAT(`t`.`transaction_date`, "%Y-%m-%d %T") AS `Transaction Date A`,
    DATE_FORMAT(`t`.`transaction_date`, "%Y-%m-%d") AS `Transaction Date`,
    `m`.`merchant_id` AS `Merchant ID`,
    `m`.`merchant_name` AS `Merchant Name`,
    `s`.`store_id` AS `Store ID`,
    `s`.`store_name` AS `Store Name`,
    `t`.`customer_id` AS `Customer ID`,
    CASE 
        WHEN `t`.`customer_name` IS NULL THEN "-"
        ELSE `t`.`customer_name`
    END AS `Customer Name`,
    CASE
        WHEN `t`.`promo_code` IS NULL THEN "-"
        ELSE `p`.`promo_code` 
    END AS `Promo Code`,
    CASE
        WHEN `t`.`promo_code` IS NULL THEN `t`.`no_voucher_type`
        ELSE `p`.`voucher_type` 
    END AS `Voucher Type`,
    CASE
        WHEN `t`.`promo_code` IS NULL THEN "-"
        ELSE `p`.`promo_category` 
    END AS `Promo Category`,
    CASE
        WHEN `t`.`promo_code` IS NULL THEN `t`.`no_promo_group`
        ELSE `p`.`promo_group` 
    END AS `Promo Group`,
    CASE
        WHEN `t`.`promo_code` IS NULL THEN "-"
        ELSE `p`.`promo_type` 
    END AS `Promo Type`,
    CASE
        WHEN `t`.`payment` IS NULL THEN 0.00
        WHEN `t`.`amount_paid` = 0.00 THEN 0.00
        ELSE `t`.`gross_amount` 
    END AS `Gross Amount`,
    CASE
        WHEN `t`.`payment` IS NULL THEN 0.00
        WHEN `t`.`amount_paid` = 0.00 THEN 0.00
        ELSE `t`.`discount` 
    END AS `Discount`,
    CASE
        WHEN `t`.`payment` IS NULL THEN 0.00
        WHEN `t`.`amount_paid` = 0.00 THEN 0.00
        ELSE `t`.`amount_discounted` 
    END AS `Amount Discounted`,
    `t`.`amount_paid` AS `Cart Amount`,
    CASE
        WHEN `t`.`payment` IN (
                'paymaya_credit_card',
                'maya',
                'maya_checkout'
            )
            THEN "Card Payment"
        WHEN `t`.`payment` IN (
                'paymaya',
                'gcash',
                'gcash_miniapp'
            )
            THEN `t`.`payment`
        ELSE "-"
    END AS `Mode of Payment`,
    `t`.`bill_status` AS `Bill Status`,
    `t`.`comm_rate_base` AS `Comm Rate Base`,
    `t`.`comm_rate_base` AS `Comm Rate Base A`,
    pg_fee_cte.commission_type AS `Commission Type`,
    CONCAT(pg_fee_cte.commission_rate, '%') AS `Commission Rate`,
    ROUND(`t`.`comm_rate_base` * (pg_fee_cte.commission_rate / 100), 2) AS `Commission Amount`,
    CASE
        WHEN pg_fee_cte.commission_type = 'Vat Exc' 
            THEN ROUND(`t`.`comm_rate_base` * (pg_fee_cte.commission_rate / 100) * 1.12, 2)
        WHEN pg_fee_cte.commission_type = 'Vat Inc' 
            THEN ROUND(`t`.`comm_rate_base` * (pg_fee_cte.commission_rate / 100), 2)
    END AS `Total Billing`,
    CONCAT(pg_fee_cte.pg_fee_rate, '%') AS `PG Fee Rate`,
    ROUND(`t`.`amount_paid` * (pg_fee_cte.pg_fee_rate / 100), 2) AS `PG Fee Amount`,
    CONCAT(pg_fee_cte.cwt_rate, '%') `CWT Rate`,
    ROUND(`t`.`amount_paid`
        - CASE
            WHEN pg_fee_cte.commission_type = 'Vat Exc' 
                THEN ROUND(`t`.`comm_rate_base` * (pg_fee_cte.commission_rate / 100) * 1.12, 2)
            WHEN pg_fee_cte.commission_type = 'Vat Inc' 
                THEN ROUND(`t`.`comm_rate_base` * (pg_fee_cte.commission_rate / 100), 2)
        END 
        - ROUND(`t`.`amount_paid` * (pg_fee_cte.pg_fee_rate / 100), 2)
    , 2) AS `Amount to be Disbursed`
FROM `leadgen_db`.`transaction` `t`
    JOIN `leadgen_db`.`store` `s` ON `t`.`store_id` = `s`.`store_id`
    JOIN `leadgen_db`.`merchant` `m` ON `m`.`merchant_id` = `s`.`merchant_id`
    JOIN `leadgen_db`.`promo` `p` ON `p`.`promo_code` = `t`.`promo_code` AND `p`.`merchant_id` = `m`.`merchant_id`
    JOIN `leadgen_db`.`fee` `f` ON `f`.`merchant_id` = `m`.`merchant_id`
    JOIN `pg_fee_cte` ON `t`.`transaction_id` = `pg_fee_cte`.`transaction_id`
WHERE pg_fee_cte.row_num = 1
ORDER BY `t`.`transaction_date` DESC;