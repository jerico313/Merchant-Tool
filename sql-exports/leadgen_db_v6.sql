-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 16, 2024 at 08:11 AM
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
-- Table structure for table `legal_entity_name`
--

CREATE TABLE `legal_entity_name` (
  `legal_entity_id` varchar(36) NOT NULL,
  `legal_entity_name` varchar(250) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `legal_entity_name`
--
DELIMITER $$
CREATE TRIGGER `generate_legal_entity_id` BEFORE INSERT ON `legal_entity_name` FOR EACH ROW BEGIN
    SET NEW.legal_entity_id = UUID(); 
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
  `offer_price` decimal(10,2) NOT NULL,
  `promo_code` varchar(100) NOT NULL,
  `promo_type` enum('Booky','Gcash','Unionbank') NOT NULL,
  `vat_type` enum('Vat Inc','Vat Ex') NOT NULL,
  `commission_rate` decimal(6,4) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `mode_of_payment` enum('cod','Paymaya','Gcash','Gcash_miniapp','Card Payment','Maya_checkout') NOT NULL,
  `rate` decimal(6,4) NOT NULL,
  `effective_date` date NOT NULL,
  `status` enum('Active','Expired') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `legal_entity_id` varchar(36) NOT NULL,
  `store_name` varchar(100) NOT NULL,
  `store_address` varchar(250) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `claim_id` varchar(36) NOT NULL,
  `transaction_date` datetime NOT NULL,
  `gross_sales` decimal(10,2) NOT NULL,
  `voucher_price` decimal(10,2) NOT NULL,
  `mode_of_payment` enum('cod','gcash','gcash_miniapp','maya','maya_checkout','maya_credit_card','paymaya') NOT NULL,
  `payment_status` enum('success','disbursed') NOT NULL,
  `pg_fee_id` varchar(36) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
-- Indexes for table `legal_entity_name`
--
ALTER TABLE `legal_entity_name`
  ADD PRIMARY KEY (`legal_entity_id`);

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
  ADD PRIMARY KEY (`pg_fee_id`);

--
-- Indexes for table `store`
--
ALTER TABLE `store`
  ADD PRIMARY KEY (`store_id`),
  ADD KEY `merchant_id` (`merchant_id`),
  ADD KEY `store_ibfk_2` (`legal_entity_id`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `store_id` (`store_id`),
  ADD KEY `offer_id` (`offer_id`),
  ADD KEY `pg_fee_id` (`pg_fee_id`);

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
-- Constraints for table `store`
--
ALTER TABLE `store`
  ADD CONSTRAINT `store_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`),
  ADD CONSTRAINT `store_ibfk_2` FOREIGN KEY (`legal_entity_id`) REFERENCES `legal_entity_name` (`legal_entity_id`);

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`),
  ADD CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`offer_id`) REFERENCES `offer` (`offer_id`),
  ADD CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`pg_fee_id`) REFERENCES `pg_fee_rate` (`pg_fee_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
