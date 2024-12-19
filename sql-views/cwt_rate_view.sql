DROP VIEW IF EXISTS cwt_rate_view;

CREATE VIEW cwt_rate_view AS
SELECT
    `c`.`cwt_rate_id` AS `cwt_rate_id`,
    `c`.`store_id` AS `store_id`,
    `s`.`store_name` AS `store_name`,
    `c`.`cwt_rate` AS `cwt_rate`,
    `c`.`effective_date` AS `effective_date`,
    `c`.`created_at` AS `created_at`,
    `c`.`updated_at` AS `updated_at`
FROM
    `leadgen_db`.`cwt_rate` `c`
JOIN
    `leadgen_db`.`store` `s` ON `s`.`store_id` = `c`.`store_id`;