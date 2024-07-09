DROP VIEW IF EXISTS transaction_summary_view;

CREATE VIEW transaction_summary_view AS
WITH pg_fee_cte AS (
    SELECT t.transaction_id,
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
                    (
                        SELECT `fh`.`old_value`
                        FROM `leadgen_db`.`fee_history` `fh`
                        WHERE `fh`.`fee_id` = `f`.`fee_id`
                            AND `fh`.`column_name` = `t`.`payment`
                            AND `fh`.`changed_at` >= `t`.`transaction_date`
                        ORDER BY `fh`.`changed_at` DESC
                        LIMIT 1
                    ), CASE
                        `t`.`payment`
                        WHEN 'paymaya_credit_card' THEN `f`.`paymaya_credit_card`
                        WHEN 'gcash' THEN `f`.`gcash`
                        WHEN 'gcash_miniapp' THEN `f`.`gcash_miniapp`
                        WHEN 'paymaya' THEN `f`.`paymaya`
                        WHEN 'maya_checkout' THEN `f`.`maya_checkout`
                        WHEN 'maya' THEN `f`.`maya`
                    END
                ))
                WHEN `t`.`payment` IS NULL THEN 0
        END AS pg_fee_rate,
        COALESCE(
        (
            SELECT `fh`.`old_value`
            FROM `leadgen_db`.`fee_history` `fh`
            WHERE `fh`.`fee_id` = `f`.`fee_id`
                AND `fh`.`column_name` = 'commission_type'
                AND `fh`.`changed_at` >= `t`.`transaction_date`
            ORDER BY `fh`.`changed_at` DESC
            LIMIT 1
        ), `f`.`commission_type`
    ) AS commission_type,
        COALESCE(
        (
            SELECT `fh`.`old_value`
            FROM `leadgen_db`.`fee_history` `fh`
            WHERE `fh`.`fee_id` = `f`.`fee_id`
                AND `fh`.`column_name` = 'lead_gen_commission'
                AND `fh`.`changed_at` >= `t`.`transaction_date`
            ORDER BY `fh`.`changed_at` DESC
            LIMIT 1
        ), `f`.`lead_gen_commission`
    ) AS commission_rate
    FROM `leadgen_db`.`transaction` `t`
        JOIN `leadgen_db`.`store` `s` ON (`t`.`store_id` = `s`.`store_id`)
        JOIN `leadgen_db`.`merchant` `m` ON (`m`.`merchant_id` = `s`.`merchant_id`)
        JOIN `leadgen_db`.`fee` `f` ON (`f`.`merchant_id` = `m`.`merchant_id`)
)
SELECT SUBSTR(`t`.`transaction_id`,1,8) AS `Transaction ID`,
    `t`.`transaction_date` AS `Transaction Date`,
    `m`.`merchant_id` AS `Merchant ID`,
    `m`.`merchant_name` AS `Merchant Name`,
    `s`.`store_id` AS `Store ID`,
    `s`.`store_name` AS `Store Name`,
    `t`.`customer_id` AS `Customer ID`,
    `t`.`customer_name` AS `Customer Name`,
    `p`.`promo_code` AS `Promo Code`,
    `p`.`voucher_type` AS `Voucher Type`,
    `p`.`promo_category` AS `Promo Category`,
    `p`.`promo_group` AS `Promo Group`,
    `p`.`promo_type` AS `Promo Type`,
    `t`.`gross_amount` AS `Gross Amount`,
    `t`.`discount` AS `Discount`,
    `t`.`amount_discounted` AS `Cart Amount`,
    `t`.`payment` AS `Payment`,
    `t`.`bill_status` AS `Bill Status`,
    `t`.`comm_rate_base` AS `Comm Rate Base`,
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
    ROUND(`t`.`amount_discounted` * (pg_fee_cte.pg_fee_rate / 100), 2) AS `PG Fee Amount`,
    ROUND(
        `t`.`amount_discounted` 
        - CASE
            WHEN pg_fee_cte.commission_type = 'Vat Exc' 
                THEN ROUND(`t`.`comm_rate_base` * (pg_fee_cte.commission_rate / 100) * 1.12, 2)
            WHEN pg_fee_cte.commission_type = 'Vat Inc' 
                THEN ROUND(`t`.`comm_rate_base` * (pg_fee_cte.commission_rate / 100), 2)
        END 
        - ROUND(`t`.`amount_discounted` * (pg_fee_cte.pg_fee_rate / 100), 2)
    , 2)
    AS `Amount to be Disbursed`
FROM `leadgen_db`.`transaction` `t`
    JOIN `leadgen_db`.`store` `s` ON `t`.`store_id` = `s`.`store_id`
    JOIN `leadgen_db`.`merchant` `m` ON `m`.`merchant_id` = `s`.`merchant_id`
    JOIN `leadgen_db`.`promo` `p` ON `p`.`promo_code` = `t`.`promo_code`
    JOIN `leadgen_db`.`fee` `f` ON `f`.`merchant_id` = `m`.`merchant_id`
    JOIN pg_fee_cte ON `t`.`transaction_id` = `pg_fee_cte`.`transaction_id`
ORDER BY `t`.`transaction_date` ASC;