-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 29, 2024 at 04:07 AM
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
  `table_name` int(11) NOT NULL,
  `table_id` int(11) NOT NULL,
  `activity_type` enum('Add','Update','Delete','Login') NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `business_address` varchar(250) NOT NULL,
  `email_address` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant`
--

INSERT INTO `merchant` (`merchant_id`, `merchant_name`, `merchant_partnership_type`, `business_address`, `email_address`, `created_at`, `updated_at`) VALUES
('3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Angel\'s Pizza', 'Primary', 'Somewhere St.', 'angelspizza@gmail.com', '2024-05-28 07:16:32', '2024-05-28 07:16:32');

-- --------------------------------------------------------

--
-- Table structure for table `offer`
--

CREATE TABLE `offer` (
  `offer_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `offer_name` varchar(100) NOT NULL,
  `offer_details` text NOT NULL,
  `offer_quantity` int(11) NOT NULL,
  `voucher_price` decimal(10,2) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `promo_type` enum('Booky','Gcash','Unionbank') NOT NULL,
  `vat_type` enum('Vat Inc','Vat Ex') NOT NULL,
  `commission_rate` decimal(6,4) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `offer`
--

INSERT INTO `offer` (`offer_id`, `merchant_id`, `offer_name`, `offer_details`, `offer_quantity`, `voucher_price`, `promo_code`, `promo_type`, `vat_type`, `commission_rate`, `created_at`, `updated_at`) VALUES
('4e3030a7-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'B1T1 Pizza', 'Buy 1 Take 1 Pizza', 50, '500.00', 'ANGELB1T1', 'Gcash', 'Vat Inc', '5.0000', '2024-05-28 07:24:22', '2024-05-28 07:24:22');

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
-- Table structure for table `offer_renewal`
--

CREATE TABLE `offer_renewal` (
  `renewal_id` varchar(36) NOT NULL,
  `offer_id` varchar(36) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `billable_date` date DEFAULT NULL,
  `status` enum('Active','Expired') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `offer_renewal`
--
DELIMITER $$
CREATE TRIGGER `generate_renewal_id` BEFORE INSERT ON `offer_renewal` FOR EACH ROW BEGIN
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
  `rate` decimal(6,4) NOT NULL,
  `effective_date` date NOT NULL,
  `status` enum('Active','Expired') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pg_fee_rate`
--

INSERT INTO `pg_fee_rate` (`pg_fee_id`, `merchant_id`, `mode_of_payment`, `rate`, `effective_date`, `status`, `created_at`, `updated_at`) VALUES
('02f361d3-1cc3-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'gcash_miniapp', '2.0000', '2024-05-01', 'Active', '2024-05-28 07:22:16', '2024-05-28 07:22:16'),
('42b4eda5-1cc5-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'gcash', '6.0000', '2024-05-28', 'Active', '2024-05-28 07:38:22', '2024-05-28 07:38:22'),
('dd887e2d-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'paymaya_credit_card', '2.5000', '2024-05-01', 'Active', '2024-05-28 07:21:13', '2024-05-28 07:21:13'),
('f24a467d-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'gcash', '2.0000', '2024-05-01', 'Expired', '2024-05-28 07:21:48', '2024-05-28 07:21:48');

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
  `legal_entity_name` varchar(100) NOT NULL,
  `store_name` varchar(100) NOT NULL,
  `store_address` varchar(250) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `store`
--

INSERT INTO `store` (`store_id`, `merchant_id`, `legal_entity_name`, `store_name`, `store_address`, `created_at`, `updated_at`) VALUES
('8946759b-1cc2-11ef-8abb-48e7dad87c24', '3606c45c-1cc2-11ef-8abb-48e7dad87c24', 'Angel Legal Name', 'Angel\'s Pizza - Mandaluyong', 'Anywhere St.', '2024-05-28 07:18:52', '2024-05-28 07:18:52');

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
('8d1552bf-1cc3-11ef-8abb-48e7dad87c24', '8946759b-1cc2-11ef-8abb-48e7dad87c24', '4e3030a7-1cc3-11ef-8abb-48e7dad87c24', 'customer123', 'Person A', '2024-05-28 09:25:43', '1000.00', 'gcash', 'success', '2024-05-28 07:26:08', '2024-05-28 07:26:08');

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
  
  INSERT INTO table_log (tableName, tableID, logType, description)
  VALUES ('user', NEW.user_id, 'Update', description);
END
$$
DELIMITER ;

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
-- Indexes for table `offer_renewal`
--
ALTER TABLE `offer_renewal`
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
-- Constraints for table `offer_renewal`
--
ALTER TABLE `offer_renewal`
  ADD CONSTRAINT `offer_renewal_ibfk_1` FOREIGN KEY (`offer_id`) REFERENCES `offer` (`offer_id`);

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
