DROP VIEW IF EXISTS store_view;

CREATE VIEW store_view AS
SELECT
    `s`.`store_id` AS `store_id`,
    `s`.`store_name` AS `store_name`,
    CASE
        WHEN `s`.`legal_entity_name` IS NULL THEN "-"
        ELSE `s`.`legal_entity_name`
    END AS `legal_entity_name`,
    CASE
        WHEN `s`.`store_address` IS NULL THEN "-"
        ELSE `s`.`store_address`
    END AS `store_address`,
    CASE
        WHEN `s`.`email_address` IS NULL THEN "-"
        ELSE `s`.`email_address`
    END AS `email_address`,
    COALESCE(
        (SELECT `cwt`.`cwt_rate`
        FROM `leadgen_db`.`cwt_rate` `cwt`
        WHERE `cwt`.`store_id` = `s`.`store_id`
        ORDER BY `cwt`.`effective_date` DESC 
        LIMIT 1), 
        0
    ) AS `cwt_rate`,
    `m`.`merchant_id` AS `merchant_id`,
    `m`.`merchant_name` AS `merchant_name`,
    `s`.`created_at` AS `created_at`,
    `s`.`updated_at` AS `updated_at`
FROM
    `leadgen_db`.`store` `s`
JOIN
    `leadgen_db`.`merchant` `m` ON `m`.`merchant_id` = `s`.`merchant_id`;