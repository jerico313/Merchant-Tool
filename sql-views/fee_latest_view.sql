DROP VIEW IF EXISTS fee_latest_view;

CREATE VIEW fee_latest_view AS
SELECT
    `f`.`fee_id` AS `fee_id`,
    `m`.`merchant_id` AS `merchant_id`,
    `m`.`merchant_name` AS `merchant_name`,
    `f`.`paymaya_credit_card` AS `paymaya_credit_card`,
    `f`.`gcash` AS `gcash`,
    `f`.`gcash_miniapp` AS `gcash_miniapp`,
    `f`.`paymaya` AS `paymaya`,
    `f`.`maya_checkout` AS `maya_checkout`,
    `f`.`maya` AS `maya`,
    `f`.`commission_type` AS `commission_type`,
    `f`.`lead_gen_commission` AS `lead_gen_commission`,
    `f`.`effective_date` AS `effective_date`,
    `f`.`created_at` AS `created_at`,
    `f`.`updated_at` AS `updated_at`
FROM
    `leadgen_db`.`fee` `f`
JOIN
    `leadgen_db`.`merchant` `m` ON `m`.`merchant_id` = `f`.`merchant_id`
WHERE
    `f`.`effective_date` = (
        SELECT MAX(`f2`.`effective_date`)
        FROM `leadgen_db`.`fee` `f2`
        WHERE `f2`.`merchant_id` = `f`.`merchant_id`
    )
ORDER BY `m`.`merchant_name` ASC;