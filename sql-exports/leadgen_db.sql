-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 04, 2024 at 10:39 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

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
('3caf218d-1f21-11ef-a08a-48e7dad87c24', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Add', 'User record added\nemail_address: admin@bookymail.ph\npassword: admin123\nname: Admin\ntype: Admin\nstatus: Active', '2024-05-31 07:41:48', '2024-05-31 07:41:48'),
('446c137a-1f21-11ef-a08a-48e7dad87c24', NULL, 'user', '3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'Update', 'User record updated\npassword: admin123 -> admin123booky', '2024-05-31 07:42:01', '2024-05-31 07:42:01');

--
-- Triggers `activity_history`
--
DELIMITER $$
CREATE TRIGGER `generate_activity_id` BEFORE INSERT ON `activity_history` FOR EACH ROW BEGIN
    SET NEW.activity_id = UUID(); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `fee`
--

CREATE TABLE `fee` (
  `fee_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `paymaya_credit_card` decimal(4,2) NOT NULL,
  `gcash` decimal(4,2) NOT NULL,
  `gcash_miniapp` decimal(4,2) NOT NULL,
  `paymaya` decimal(4,2) NOT NULL,
  `maya_checkout` decimal(4,2) NOT NULL,
  `maya` decimal(4,2) NOT NULL,
  `lead_gen_commission` decimal(4,2) NOT NULL,
  `commission_type` enum('VAT Inc','VAT Exc') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fee`
--

INSERT INTO `fee` (`fee_id`, `merchant_id`, `paymaya_credit_card`, `gcash`, `gcash_miniapp`, `paymaya`, `maya_checkout`, `maya`, `lead_gen_commission`, `commission_type`, `created_at`, `updated_at`) VALUES
('02f361d3-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', '5.00', '3.00', '3.00', '2.50', '2.00', '2.00', '5.00', 'VAT Inc', '2024-05-28 07:22:16', '2024-06-04 04:34:38');

--
-- Triggers `fee`
--
DELIMITER $$
CREATE TRIGGER `generate_fee_id` BEFORE INSERT ON `fee` FOR EACH ROW BEGIN
    SET NEW.fee_id = UUID(); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_fee_log` AFTER UPDATE ON `fee` FOR EACH ROW BEGIN
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
  `changed_at` date NOT NULL DEFAULT current_timestamp(),
  `changed_by` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fee_history`
--

INSERT INTO `fee_history` (`fee_history_id`, `fee_id`, `column_name`, `old_value`, `new_value`, `changed_at`, `changed_by`) VALUES
('04a53aab-223f-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'gcash', '2.75', '3.00', '2024-06-04', NULL),
('04a54436-223f-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'gcash_miniapp', '2.75', '3.00', '2024-06-04', NULL),
('66638ca3-2241-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'paymaya', '2.00', '2.50', '2024-06-04', NULL),
('9469bad9-2241-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'lead_gen_commission', '10.00', '5.00', '2024-06-04', NULL),
('9469bebf-2241-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'commission_type', 'VAT Exc', 'VAT Inc', '2024-06-04', NULL),
('b538bee7-224a-11ef-b01f-48e7dad87c24', '02f361d3-1cc3-11ef-8abb-48e7dad87c24', 'paymaya_credit_card', '2.00', '5.00', '2024-06-01', NULL);

--
-- Triggers `fee_history`
--
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
  `merchant_name` varchar(100) NOT NULL,
  `merchant_partnership_type` enum('Primary','Secondary') NOT NULL,
  `merchant_type` enum('Grab & Go','Casual Dining') NOT NULL,
  `business_address` varchar(250) NOT NULL,
  `email_address` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant`
--

INSERT INTO `merchant` (`merchant_id`, `merchant_name`, `merchant_partnership_type`, `merchant_type`, `business_address`, `email_address`, `created_at`, `updated_at`) VALUES
('3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B00KY Demo Merchant', 'Primary', 'Grab & Go', 'Somewhere St.', 'merchantdemo@booky.ph', '2024-05-28 07:16:32', '2024-06-04 02:49:53');

-- --------------------------------------------------------

--
-- Table structure for table `promo`
--

CREATE TABLE `promo` (
  `promo_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `promo_amount` int(11) NOT NULL,
  `promo_type` enum('Coupled','Decoupled') NOT NULL,
  `promo_group` enum('Booky','Gcash','Unionbank','Gcash/Booky','UB/Booky') NOT NULL,
  `promo_details` text NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `billable_date` date NOT NULL,
  `status` enum('Pre-trial','Billable','Not Billable','Expired') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promo`
--

INSERT INTO `promo` (`promo_id`, `merchant_id`, `promo_code`, `promo_amount`, `promo_type`, `promo_group`, `promo_details`, `start_date`, `end_date`, `billable_date`, `status`, `created_at`, `updated_at`) VALUES
('4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B00KYDEMO', 100, 'Coupled', 'UB/Booky', 'Booky sample promo', '2024-04-01', '2024-05-31', '2024-06-04', 'Pre-trial', '2024-06-04 02:34:19', '2024-06-04 02:34:49');

--
-- Triggers `promo`
--
DELIMITER $$
CREATE TRIGGER `generate_offer_id` BEFORE INSERT ON `promo` FOR EACH ROW BEGIN
    SET NEW.offer_id = UUID(); 
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
  `legal_entity_name` varchar(100) NOT NULL,
  `store_address` varchar(250) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `store`
--

INSERT INTO `store` (`store_id`, `merchant_id`, `store_name`, `legal_entity_name`, `store_address`, `created_at`, `updated_at`) VALUES
('8946759b-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B00KY Demo Store', 'Demo Legal Name', 'Anywhere St.', '2024-05-28 07:18:52', '2024-06-04 02:56:04');

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `transaction_id` varchar(36) NOT NULL,
  `store_id` varchar(36) NOT NULL,
  `promo_id` varchar(36) NOT NULL,
  `customer_id` varchar(36) NOT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `transaction_date` datetime NOT NULL,
  `gross_amount` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) NOT NULL,
  `amount_discounted` decimal(10,2) NOT NULL,
  `mode_of_payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya','lead gen') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`transaction_id`, `store_id`, `promo_id`, `customer_id`, `customer_name`, `transaction_date`, `gross_amount`, `discount`, `amount_discounted`, `mode_of_payment`, `created_at`, `updated_at`) VALUES
('1bc0f5fe-224b-11ef-b01f-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '09121234345', 'Maria Demo', '2024-06-01 16:17:58', '20760.00', '5190.00', '15570.00', 'paymaya_credit_card', '2024-06-01 08:17:58', '2024-06-01 08:17:58'),
('8d1552bf-1cc3-11ef-8abb-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '09123456789', 'Juan Person', '2024-05-28 09:25:43', '1484.00', '594.00', '890.00', 'gcash', '2024-05-28 07:26:08', '2024-05-28 07:26:08'),
('e881c2e7-224a-11ef-b01f-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '09987654321', 'Anna Human', '2024-06-06 10:16:20', '15570.00', '3114.00', '12456.00', 'paymaya_credit_card', '2024-06-04 08:17:39', '2024-06-04 08:17:39');

-- --------------------------------------------------------

--
-- Stand-in structure for view `transaction_view`
-- (See below for the actual view)
--
CREATE TABLE `transaction_view` (
`Transaction ID` varchar(36)
,`Transaction Date` datetime
,`Store Name` varchar(100)
,`Merchant Name` varchar(100)
,`Customer ID` varchar(36)
,`Customer Name` varchar(100)
,`Promo ID` varchar(36)
,`Promo Code` varchar(100)
,`Gross Amount` decimal(10,2)
,`Discount` decimal(10,2)
,`Amount Discounted` decimal(10,2)
,`Mode of Payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya','lead gen')
,`Commission Type` enum('VAT Inc','VAT Exc')
,`Commission Rate` varchar(7)
,`Commission Amount` decimal(13,2)
,`Total Billing` decimal(14,2)
,`PG Fee Rate` varchar(7)
,`PG Fee Amount` decimal(13,2)
,`Amount to be Disbursed` decimal(16,2)
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
  `type` enum('Admin','User') NOT NULL,
  `status` enum('Active','Inactive') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `email_address`, `password`, `name`, `type`, `status`, `created_at`, `updated_at`) VALUES
('3ca941c5-1f21-11ef-a08a-48e7dad87c24', 'admin@bookymail.ph', 'admin123booky', 'Admin', 'Admin', 'Active', '2024-05-31 07:41:48', '2024-05-31 07:41:48');

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
-- Structure for view `transaction_view`
--
DROP TABLE IF EXISTS `transaction_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_view`  AS SELECT `t`.`transaction_id` AS `Transaction ID`, `t`.`transaction_date` AS `Transaction Date`, `s`.`store_name` AS `Store Name`, `m`.`merchant_name` AS `Merchant Name`, `t`.`customer_id` AS `Customer ID`, `t`.`customer_name` AS `Customer Name`, `p`.`promo_id` AS `Promo ID`, `p`.`promo_code` AS `Promo Code`, `t`.`gross_amount` AS `Gross Amount`, `t`.`discount` AS `Discount`, `t`.`amount_discounted` AS `Amount Discounted`, `t`.`mode_of_payment` AS `Mode of Payment`, `f`.`commission_type` AS `Commission Type`, concat(`f`.`lead_gen_commission`,'%') AS `Commission Rate`, round(`t`.`amount_discounted` * (`f`.`lead_gen_commission` / 100),2) AS `Commission Amount`, CASE WHEN `f`.`commission_type` = 'Vat Exc' THEN round(`t`.`amount_discounted` * (`f`.`lead_gen_commission` / 100) * 1.12,2) WHEN `f`.`commission_type` = 'Vat Inc' THEN round(`t`.`amount_discounted` * (`f`.`lead_gen_commission` / 100),2) END AS `Total Billing`, CASE WHEN `t`.`mode_of_payment` = 'paymaya_credit_card' THEN concat(`f`.`paymaya_credit_card`,'%') WHEN `t`.`mode_of_payment` = 'gcash' THEN concat(`f`.`gcash`,'%') WHEN `t`.`mode_of_payment` = 'gcash_miniapp' THEN concat(`f`.`gcash_miniapp`,'%') WHEN `t`.`mode_of_payment` = 'paymaya' THEN concat(`f`.`paymaya`,'%') WHEN `t`.`mode_of_payment` = 'maya_checkout' THEN concat(`f`.`maya_checkout`,'%') WHEN `t`.`mode_of_payment` = 'maya' THEN concat(`f`.`maya`,'%') END AS `PG Fee Rate`, CASE WHEN `t`.`mode_of_payment` = 'paymaya_credit_card' THEN round(`t`.`amount_discounted` * (`f`.`paymaya_credit_card` / 100),2) WHEN `t`.`mode_of_payment` = 'gcash' THEN round(`t`.`amount_discounted` * (`f`.`gcash` / 100),2) WHEN `t`.`mode_of_payment` = 'gcash_miniapp' THEN round(`t`.`amount_discounted` * (`f`.`gcash_miniapp` / 100),2) WHEN `t`.`mode_of_payment` = 'paymaya' THEN round(`t`.`amount_discounted` * (`f`.`paymaya` / 100),2) WHEN `t`.`mode_of_payment` = 'maya_checkout' THEN round(`t`.`amount_discounted` * (`f`.`maya_checkout` / 100),2) WHEN `t`.`mode_of_payment` = 'maya' THEN round(`t`.`amount_discounted` * (`f`.`maya` / 100),2) END AS `PG Fee Amount`, round(`t`.`amount_discounted` - case when `f`.`commission_type` = 'Vat Exc' then round(`t`.`amount_discounted` * (`f`.`lead_gen_commission` / 100) * 1.12,2) when `f`.`commission_type` = 'Vat Inc' then round(`t`.`amount_discounted` * (`f`.`lead_gen_commission` / 100),2) end - case when `t`.`mode_of_payment` = 'paymaya_credit_card' then round(`t`.`amount_discounted` * (`f`.`paymaya_credit_card` / 100),2) when `t`.`mode_of_payment` = 'gcash' then round(`t`.`amount_discounted` * (`f`.`gcash` / 100),2) when `t`.`mode_of_payment` = 'gcash_miniapp' then round(`t`.`amount_discounted` * (`f`.`gcash_miniapp` / 100),2) when `t`.`mode_of_payment` = 'paymaya' then round(`t`.`amount_discounted` * (`f`.`paymaya` / 100),2) when `t`.`mode_of_payment` = 'maya_checkout' then round(`t`.`amount_discounted` * (`f`.`maya_checkout` / 100),2) when `t`.`mode_of_payment` = 'maya' then round(`t`.`amount_discounted` * (`f`.`maya` / 100),2) end,2) AS `Amount to be Disbursed` FROM ((((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `merchant` `m` on(`m`.`merchant_id` = `s`.`merchant_id`)) join `promo` `p` on(`p`.`merchant_id` = `m`.`merchant_id`)) join `fee` `f` on(`f`.`merchant_id` = `m`.`merchant_id`))  ;

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
  ADD UNIQUE KEY `pg_fee_rate_ibfk_1` (`merchant_id`) USING BTREE;

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
  ADD PRIMARY KEY (`promo_id`),
  ADD KEY `merchant_id` (`merchant_id`);

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
  ADD KEY `offer_id` (`promo_id`);

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
-- Constraints for table `store`
--
ALTER TABLE `store`
  ADD CONSTRAINT `store_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`),
  ADD CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`promo_id`) REFERENCES `promo` (`promo_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
