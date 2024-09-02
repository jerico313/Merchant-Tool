DROP VIEW IF EXISTS activity_history_view;

CREATE VIEW activity_history_view AS
SELECT
    SUBSTR(`a`.`activity_id`, 1, 8) AS `activity_history_id`,
    SUBSTR(COALESCE(`a`.`user_id`, 'xxxxxxxx'), 1, 8) AS `user_id`,
    COALESCE(`u`.`name`, 'Unknown user') AS `user_name`,
    `a`.`table_name` AS `table_name`,
    SUBSTR(
        COALESCE(
            CASE
                WHEN `a`.`table_name` = 'merchant' THEN `m`.`merchant_id`
                WHEN `a`.`table_name` = 'store' THEN `s`.`store_id`
                WHEN `a`.`table_name` = 'promo' THEN `p`.`promo_id`
                WHEN `a`.`table_name` = 'fee' THEN `f`.`fee_id`
                WHEN `a`.`table_name` = 'transaction' THEN `t`.`transaction_id`
                WHEN `a`.`table_name` = 'report_history_coupled' THEN `rhc`.`coupled_report_id`
                WHEN `a`.`table_name` = 'report_history_decoupled' THEN `rhd`.`decoupled_report_id`
                WHEN `a`.`table_name` = 'report_history_gcash_head' THEN `rhgh`.`gcash_report_id`
                WHEN `a`.`table_name` = 'report_history_gcash_body' THEN `rhgb`.`gcash_report_body_id`
                ELSE `a`.`table_id`
            END,
            `a`.`table_id`
        ),
        1,
        8
    ) AS `table_id`,
    COALESCE(
        CASE
            WHEN `a`.`table_name` = 'merchant' THEN `m`.`merchant_name`
            WHEN `a`.`table_name` = 'store' THEN `s`.`store_name`
            WHEN `a`.`table_name` = 'promo' THEN `p`.`promo_code`
            WHEN `a`.`table_name` = 'fee' THEN `fm`.`merchant_name`
            WHEN `a`.`table_name` = 'transaction' THEN `t`.`customer_id`
            WHEN `a`.`table_name` = 'report_history_coupled' THEN `rhc`.`settlement_number`
            WHEN `a`.`table_name` = 'report_history_decoupled' THEN `rhd`.`settlement_number`
            WHEN `a`.`table_name` = 'report_history_gcash_head' THEN `rhgh`.`settlement_number`
            WHEN `a`.`table_name` = 'report_history_gcash_body' THEN `rhgh2`.`settlement_number`
            ELSE NULL
        END,
        'Deleted'
    ) AS `column_name`,
    `a`.`activity_type` AS `activity_type`,
    `a`.`description` AS `description`,
    CASE
        WHEN TIMESTAMPDIFF(SECOND, `a`.`created_at`, NOW()) < 60 THEN
            CONCAT(TIMESTAMPDIFF(SECOND, `a`.`created_at`, NOW()), ' second', IF(TIMESTAMPDIFF(SECOND, `a`.`created_at`, NOW()) = 1, '', 's'), ' ago')
        WHEN TIMESTAMPDIFF(MINUTE, `a`.`created_at`, NOW()) < 60 THEN
            CONCAT(TIMESTAMPDIFF(MINUTE, `a`.`created_at`, NOW()), ' minute', IF(TIMESTAMPDIFF(MINUTE, `a`.`created_at`, NOW()) = 1, '', 's'), ' ago')
        WHEN TIMESTAMPDIFF(HOUR, `a`.`created_at`, NOW()) < 24 THEN
            CONCAT(TIMESTAMPDIFF(HOUR, `a`.`created_at`, NOW()), ' hour', IF(TIMESTAMPDIFF(HOUR, `a`.`created_at`, NOW()) = 1, '', 's'), ' ago')
        WHEN TIMESTAMPDIFF(DAY, `a`.`created_at`, NOW()) < 7 THEN
            CONCAT(TIMESTAMPDIFF(DAY, `a`.`created_at`, NOW()), ' day', IF(TIMESTAMPDIFF(DAY, `a`.`created_at`, NOW()) = 1, '', 's'), ' ago at ', DATE_FORMAT(`a`.`created_at`, '%l:%i%p'))
        ELSE DATE_FORMAT(`a`.`created_at`, '%M %d at %l:%i%p')
    END AS `time_ago`,
    `a`.`created_at` AS `created_at`,
    `a`.`updated_at` AS `updated_at`
FROM
    `leadgen_db`.`activity_history` `a`
    LEFT JOIN `leadgen_db`.`user` `u` ON `u`.`user_id` = `a`.`user_id`
    LEFT JOIN `leadgen_db`.`merchant` `m` ON `a`.`table_id` = `m`.`merchant_id`
    LEFT JOIN `leadgen_db`.`store` `s` ON `a`.`table_id` = `s`.`store_id`
    LEFT JOIN `leadgen_db`.`promo` `p` ON `a`.`table_id` = `p`.`promo_id`
    LEFT JOIN `leadgen_db`.`fee` `f` ON `a`.`table_id` = `f`.`fee_id`
    LEFT JOIN `leadgen_db`.`merchant` `fm` ON `f`.`merchant_id` = `fm`.`merchant_id`
    LEFT JOIN `leadgen_db`.`transaction` `t` ON `a`.`table_id` = `t`.`transaction_id`
    LEFT JOIN `leadgen_db`.`report_history_coupled` `rhc` ON `a`.`table_id` = `rhc`.`coupled_report_id`
    LEFT JOIN `leadgen_db`.`report_history_decoupled` `rhd` ON `a`.`table_id` = `rhd`.`decoupled_report_id`
    LEFT JOIN `leadgen_db`.`report_history_gcash_head` `rhgh` ON `a`.`table_id` = `rhgh`.`gcash_report_id`
    LEFT JOIN `leadgen_db`.`report_history_gcash_body` `rhgb` ON `a`.`table_id` = `rhgb`.`gcash_report_body_id`
    LEFT JOIN `leadgen_db`.`report_history_gcash_head` `rhgh2` ON `rhgh2`.`gcash_report_id` = `rhgb`.`gcash_report_id`
WHERE
    `a`.`table_name` IN(
        'merchant',
        'store',
        'promo',
        'fee',
        'transaction',
        'report_history_coupled',
        'report_history_decoupled',
        'report_history_gcash_head',
        'report_history_gcash_body'
    ) 
ORDER BY `a`.`created_at` DESC