-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 31, 2024 at 09:47 AM
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
-- Table structure for table `category_history`
--

CREATE TABLE `category_history` (
  `category_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) DEFAULT NULL,
  `category_name` enum('Coupled','Decoupled','Gcash') DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('Active','Expired') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `category_history`
--

INSERT INTO `category_history` (`category_id`, `merchant_id`, `category_name`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`) VALUES
('568c917b-1f13-11ef-a08a-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Coupled', '2024-03-01', '2024-06-30', 'Active', '2024-05-31 06:02:18', '2024-05-31 06:02:18');

--
-- Triggers `category_history`
--
DELIMITER $$
CREATE TRIGGER `generate_category_id` BEFORE INSERT ON `category_history` FOR EACH ROW BEGIN
    SET NEW.category_id = UUID(); 
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
('3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Angel\'s Pizza', 'Primary', 'Grab & Go', 'Somewhere St.', 'angelspizza@gmail.com', '2024-05-28 07:16:32', '2024-05-28 07:16:32');

-- --------------------------------------------------------

--
-- Table structure for table `offer`
--

CREATE TABLE `offer` (
  `offer_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `offer_name` varchar(100) NOT NULL,
  `offer_details` text NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `promo_type` enum('Booky','Gcash','Unionbank') NOT NULL,
  `vat_type` enum('Vat Inc','Vat Ex') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `offer`
--

INSERT INTO `offer` (`offer_id`, `merchant_id`, `offer_name`, `offer_details`, `promo_code`, `promo_type`, `vat_type`, `created_at`, `updated_at`) VALUES
('4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Angel Buy 1 Take 1 Pizza', 'Buy 1 Take 1 Pizza', 'ANGELB1T1', 'Gcash', 'Vat Inc', '2024-05-28 07:24:22', '2024-05-28 07:24:22');

--
-- Triggers `offer`
--
DELIMITER $$
CREATE TRIGGER `generate_offer_id` BEFORE INSERT ON `offer` FOR EACH ROW BEGIN
    SET NEW.offer_id = UUID(); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `offer_history`
--

CREATE TABLE `offer_history` (
  `renewal_id` varchar(36) NOT NULL,
  `offer_id` varchar(36) DEFAULT NULL,
  `offer_quantity` int(11) NOT NULL,
  `voucher_price` decimal(10,2) NOT NULL,
  `commission_rate` decimal(4,2) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `billable_date` date DEFAULT NULL,
  `status` enum('Active','Expired') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `offer_history`
--

INSERT INTO `offer_history` (`renewal_id`, `offer_id`, `offer_quantity`, `voucher_price`, `commission_rate`, `start_date`, `end_date`, `billable_date`, `status`, `created_at`, `updated_at`) VALUES
('6fcf5c0b-1f14-11ef-a08a-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 100, '200.00', '4.00', '2024-04-01', '2024-06-30', '2024-04-08', 'Active', '2024-05-31 06:10:10', '2024-05-31 07:25:58');

--
-- Triggers `offer_history`
--
DELIMITER $$
CREATE TRIGGER `generate_renewal_id` BEFORE INSERT ON `offer_history` FOR EACH ROW BEGIN
    SET NEW.renewal_id = UUID(); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pg_fee_rate`
--

CREATE TABLE `pg_fee_rate` (
  `pg_fee_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `mode_of_payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya','lead gen') NOT NULL,
  `rate` decimal(4,2) NOT NULL,
  `effective_date` date NOT NULL,
  `status` enum('Active','Expired') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pg_fee_rate`
--

INSERT INTO `pg_fee_rate` (`pg_fee_id`, `merchant_id`, `mode_of_payment`, `rate`, `effective_date`, `status`, `created_at`, `updated_at`) VALUES
('02f361d3-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'gcash_miniapp', '2.00', '2024-05-01', 'Active', '2024-05-28 07:22:16', '2024-05-28 07:22:16'),
('42b4eda5-1cc5-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'gcash', '5.00', '2024-05-27', 'Active', '2024-05-28 07:38:22', '2024-05-28 07:38:22'),
('dd887e2d-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'paymaya_credit_card', '2.50', '2024-05-01', 'Active', '2024-05-28 07:21:13', '2024-05-28 07:21:13'),
('f24a467d-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'gcash', '2.00', '2024-05-01', 'Expired', '2024-05-28 07:21:48', '2024-05-28 07:21:48');

--
-- Triggers `pg_fee_rate`
--
DELIMITER $$
CREATE TRIGGER `generate_pg_fee_rate_id` BEFORE INSERT ON `pg_fee_rate` FOR EACH ROW BEGIN
    SET NEW.pg_fee_id = UUID(); 
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
('8946759b-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Angel\'s Pizza - Mandaluyong', 'Angel Legal Name', 'Anywhere St.', '2024-05-28 07:18:52', '2024-05-28 07:18:52');

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `transaction_id` varchar(36) NOT NULL,
  `store_id` varchar(36) NOT NULL,
  `offer_id` varchar(36) NOT NULL,
  `customer_id` varchar(36) NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `transaction_date` datetime NOT NULL,
  `gross_sales` decimal(10,2) NOT NULL,
  `mode_of_payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya','lead gen') NOT NULL,
  `payment_status` enum('success','disbursed') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`transaction_id`, `store_id`, `offer_id`, `customer_id`, `customer_name`, `transaction_date`, `gross_sales`, `mode_of_payment`, `payment_status`, `created_at`, `updated_at`) VALUES
('8d1552bf-1cc3-11ef-8abb-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '09123456789', 'Juan Person', '2024-05-28 09:25:43', '1000.00', 'gcash', 'success', '2024-05-28 07:26:08', '2024-05-28 07:26:08');

-- --------------------------------------------------------

--
-- Stand-in structure for view `transaction_summary_view`
-- (See below for the actual view)
--
CREATE TABLE `transaction_summary_view` (
`Store Name` varchar(100)
,`Customer Name` varchar(100)
,`Customer ID` varchar(36)
,`Transaction ID` varchar(36)
,`Transaction Date` date
,`Offer ID` varchar(36)
,`Promo Code` varchar(100)
,`Gross Sales` decimal(10,2)
,`Net Amount` decimal(11,2)
,`Mode of Payment` enum('paymaya_credit_card','gcash','gcash_miniapp','paymaya','maya_checkout','maya','lead gen')
,`Commission Rate` varchar(7)
,`Commission Amount` decimal(14,2)
,`PG Fee Rate` varchar(7)
,`PG Fee Amount` decimal(14,2)
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
  `type` enum('Admin','User_full','User_partial') NOT NULL,
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
-- Structure for view `transaction_summary_view`
--
DROP TABLE IF EXISTS `transaction_summary_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_summary_view`  AS SELECT `s`.`store_name` AS `Store Name`, `t`.`customer_name` AS `Customer Name`, `t`.`customer_id` AS `Customer ID`, `t`.`transaction_id` AS `Transaction ID`, cast(`t`.`transaction_date` as date) AS `Transaction Date`, `th`.`offer_id` AS `Offer ID`, `o`.`promo_code` AS `Promo Code`, `t`.`gross_sales` AS `Gross Sales`, `t`.`gross_sales`- `th`.`voucher_price` AS `Net Amount`, `t`.`mode_of_payment` AS `Mode of Payment`, concat(`th`.`commission_rate`,'%') AS `Commission Rate`, round((`t`.`gross_sales` - `th`.`voucher_price`) * (`th`.`commission_rate` / 100),2) AS `Commission Amount`, concat(round(`p`.`rate`,2),'%') AS `PG Fee Rate`, round((`t`.`gross_sales` - `th`.`voucher_price`) * (`p`.`rate` / 100),2) AS `PG Fee Amount`, round(`t`.`gross_sales` - `th`.`voucher_price` - (`t`.`gross_sales` - `th`.`voucher_price`) * (`th`.`commission_rate` / 100) - (`t`.`gross_sales` - `th`.`voucher_price`) * (`p`.`rate` / 100),2) AS `Amount to be Disbursed` FROM ((((`transaction` `t` join `store` `s` on(`t`.`store_id` = `s`.`store_id`)) join `offer_history` `th` on(`t`.`offer_id` = `th`.`offer_id` and `t`.`transaction_date` between `th`.`start_date` and `th`.`end_date`)) join `offer` `o` on(`th`.`offer_id` = `o`.`offer_id`)) join `pg_fee_rate` `p` on(`s`.`merchant_id` = `p`.`merchant_id` and `t`.`transaction_date` between `p`.`effective_date` and ifnull(`p`.`updated_at`,curdate()) and `p`.`effective_date` = (select max(`p2`.`effective_date`) from `pg_fee_rate` `p2` where `p2`.`merchant_id` = `p`.`merchant_id` and `t`.`transaction_date` between `p2`.`effective_date` and ifnull(`p2`.`updated_at`,curdate())))) WHERE `t`.`created_at` is not nullnot null  ;

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
-- Indexes for table `category_history`
--
ALTER TABLE `category_history`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `merchant`
--
ALTER TABLE `merchant`
  ADD PRIMARY KEY (`merchant_id`);

--
-- Indexes for table `offer`
--
ALTER TABLE `offer`
  ADD PRIMARY KEY (`offer_id`),
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `offer_history`
--
ALTER TABLE `offer_history`
  ADD PRIMARY KEY (`renewal_id`),
  ADD KEY `offer_id` (`offer_id`);

--
-- Indexes for table `pg_fee_rate`
--
ALTER TABLE `pg_fee_rate`
  ADD PRIMARY KEY (`pg_fee_id`),
  ADD KEY `pg_fee_rate_ibfk_1` (`merchant_id`);

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
  ADD KEY `offer_id` (`offer_id`);

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
-- Constraints for table `category_history`
--
ALTER TABLE `category_history`
  ADD CONSTRAINT `category_history_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `offer`
--
ALTER TABLE `offer`
  ADD CONSTRAINT `offer_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `offer_history`
--
ALTER TABLE `offer_history`
  ADD CONSTRAINT `offer_history_ibfk_1` FOREIGN KEY (`offer_id`) REFERENCES `offer` (`offer_id`);

--
-- Constraints for table `pg_fee_rate`
--
ALTER TABLE `pg_fee_rate`
  ADD CONSTRAINT `pg_fee_rate_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

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
  ADD CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`offer_id`) REFERENCES `offer` (`offer_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
