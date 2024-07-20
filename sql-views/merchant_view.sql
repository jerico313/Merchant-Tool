DROP VIEW IF EXISTS merchant_view;

CREATE VIEW merchant_view AS
SELECT
    `m`.`merchant_id` AS `merchant_id`,
    `m`.`merchant_name` AS `merchant_name`,
    `m`.`merchant_partnership_type` AS `merchant_partnership_type`,
    CASE
        WHEN `m`.`legal_entity_name` IS NULL THEN "-"
        ELSE `m`.`legal_entity_name`
    END AS `legal_entity_name`,
    CASE
        WHEN `m`.`business_address` IS NULL THEN "-"
        ELSE `m`.`business_address`
    END AS `business_address`,
    CASE
        WHEN `m`.`email_address` IS NULL THEN "-"
        ELSE `m`.`email_address`
    END AS `email_address`,
    CASE
        WHEN `m`.`sales` IS NULL THEN "-"
        ELSE `m`.`sales`
    END AS `sales_id`,
    CASE
        WHEN `m`.`sales` IS NULL THEN "No assigned person"
        ELSE `u1`.`name`
    END AS `sales`,
    CASE
        WHEN `m`.`account_manager` IS NULL THEN "-"
        ELSE `m`.`account_manager`
    END AS `account_manager_id`,
    CASE
        WHEN `m`.`account_manager` IS NULL THEN "No assigned person"
        ELSE `u2`.`name`
    END AS `account_manager`,
    `m`.`created_at` AS `created_at`,
    `m`.`updated_at` AS `updated_at`
FROM
    `leadgen_db`.`merchant` `m`
    LEFT JOIN `leadgen_db`.`user` `u1` ON `u1`.`user_id` = `m`.`sales`
    LEFT JOIN `leadgen_db`.`user` `u2` ON `u2`.`user_id` = `m`.`account_manager`;