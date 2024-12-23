DROP VIEW IF EXISTS promo_view;

CREATE VIEW promo_view AS
SELECT
    `p`.`promo_id` AS `promo_id`,
    `p`.`promo_code` AS `promo_code`,
    `m`.`merchant_id` AS `merchant_id`,
    `m`.`merchant_name` AS `merchant_name`,
    FORMAT(`p`.`promo_amount`, 2) AS `promo_amount`,
    `p`.`voucher_type` AS `voucher_type`,
    CASE
        WHEN `p`.`promo_category` IS NULL THEN "-"
        ELSE `p`.`promo_category`
    END AS `promo_category`,
    CASE
        WHEN `p`.`promo_group` IS NULL THEN "-"
        ELSE `p`.`promo_group`
    END AS `promo_group`,
    CASE
        WHEN `p`.`promo_type` IS NULL THEN "-"
        ELSE `p`.`promo_type`
    END AS `promo_type`,
    CASE
        WHEN `p`.`promo_details` IS NULL THEN "-"
        ELSE `p`.`promo_details`
    END AS `promo_details`,
    CASE
        WHEN `p`.`remarks` IS NULL THEN "-"
        ELSE `p`.`remarks`
    END AS `remarks`,
    `p`.`bill_status` AS `bill_status`,
    CASE
        WHEN `p`.`start_date` IS NULL THEN "No Start Date"
        ELSE `p`.`start_date`
    END AS `start_date`,
    CASE
        WHEN `p`.`end_date` IS NULL THEN "No End Date"
        ELSE `p`.`end_date`
    END AS `end_date`,
    CASE
        WHEN `p`.`finance_am` IS NULL THEN "-"
        ELSE `p`.`finance_am`
    END AS `finance_am`,
    `p`.`created_at` AS `created_at`,
    `p`.`updated_at` AS `updated_at`
FROM
    `leadgen_db`.`promo` `p`
JOIN
    `leadgen_db`.`merchant` `m` ON `m`.`merchant_id` = `p`.`merchant_id`;