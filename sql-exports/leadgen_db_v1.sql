-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 25, 2024 at 08:35 AM
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
-- Table structure for table `coupled_order`
--

CREATE TABLE `coupled_order` (
  `coupled_id` varchar(36) NOT NULL,
  `store_id` varchar(36) NOT NULL,
  `offer_id` varchar(36) NOT NULL,
  `customer_id` varchar(36) NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `transaction_number` varchar(100) NOT NULL,
  `transaction_date` datetime NOT NULL,
  `offer_price` decimal(10,2) NOT NULL,
  `gross_sales` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) NOT NULL,
  `payment_method` enum('cod','Paymaya','Gcash','Gcash_miniapp','Card Payment','Maya_checkout') NOT NULL,
  `commission_rate` decimal(6,4) NOT NULL,
  `pg_fee_id` varchar(36) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `decoupled_order`
--

CREATE TABLE `decoupled_order` (
  `decoupled_id` varchar(36) NOT NULL,
  `store_id` varchar(36) NOT NULL,
  `offer_id` varchar(36) NOT NULL,
  `customer_id` varchar(36) NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `transaction_number` varchar(100) NOT NULL,
  `transaction_date` datetime NOT NULL,
  `offer_price` decimal(10,2) NOT NULL,
  `gross_sales` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) NOT NULL,
  `payment_method` enum('cod','Paymaya','Gcash','Gcash_miniapp','Card Payment','Maya_checkout') NOT NULL,
  `commission_rate` decimal(6,4) NOT NULL,
  `pg_fee_id` varchar(36) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gcash_order`
--

CREATE TABLE `gcash_order` (
  `gcash_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `item` varchar(250) NOT NULL,
  `total_redemptions` int(11) NOT NULL,
  `voucher_price` decimal(10,2) NOT NULL,
  `commission_rate` decimal(6,4) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `merchant`
--

CREATE TABLE `merchant` (
  `merchant_id` varchar(36) NOT NULL,
  `merchant_name` varchar(100) NOT NULL,
  `merchant_type` enum('Primary','Secondary') NOT NULL,
  `legal_entity_name` varchar(250) NOT NULL,
  `lead_gen_type` enum('Decoupled','Coupled','Gcash') NOT NULL,
  `business_address` varchar(250) NOT NULL,
  `email_address` varchar(100) NOT NULL,
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
  `offer_type` enum('Couple','Decoupled','Gcash') NOT NULL,
  `offer_quantity` int(11) NOT NULL,
  `offer_amount` decimal(10,2) NOT NULL,
  `voucher_code` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `billable_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pg_fee`
--

CREATE TABLE `pg_fee` (
  `pg_fee_id` varchar(36) NOT NULL,
  `payment_method` enum('cod','Paymaya','Gcash','Gcash_miniapp','Card Payment','Maya_checkout') NOT NULL,
  `pg_fee_rate` decimal(6,4) NOT NULL,
  `effective_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `store`
--

CREATE TABLE `store` (
  `store_id` varchar(36) NOT NULL,
  `merchant_id` varchar(36) NOT NULL,
  `store_name` varchar(100) NOT NULL,
  `store_address` varchar(250) NOT NULL,
  `commission_rate` decimal(6,4) NOT NULL,
  `vat_type` enum('Vat Inc','Vat Ex') NOT NULL,
  `fulfillment_type` enum('Lead Gen','QR/MAPS Lead Gen','Gcash') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` varchar(36) NOT NULL,
  `email_address` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `coupled_order`
--
ALTER TABLE `coupled_order`
  ADD PRIMARY KEY (`coupled_id`),
  ADD KEY `store_id` (`store_id`),
  ADD KEY `offer_id` (`offer_id`),
  ADD KEY `pg_fee_id` (`pg_fee_id`);

--
-- Indexes for table `decoupled_order`
--
ALTER TABLE `decoupled_order`
  ADD PRIMARY KEY (`decoupled_id`),
  ADD KEY `store_id` (`store_id`),
  ADD KEY `offer_id` (`offer_id`),
  ADD KEY `pg_fee_id` (`pg_fee_id`);

--
-- Indexes for table `gcash_order`
--
ALTER TABLE `gcash_order`
  ADD PRIMARY KEY (`gcash_id`),
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
-- Indexes for table `pg_fee`
--
ALTER TABLE `pg_fee`
  ADD PRIMARY KEY (`pg_fee_id`);

--
-- Indexes for table `store`
--
ALTER TABLE `store`
  ADD PRIMARY KEY (`store_id`),
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `coupled_order`
--
ALTER TABLE `coupled_order`
  ADD CONSTRAINT `coupled_order_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`),
  ADD CONSTRAINT `coupled_order_ibfk_2` FOREIGN KEY (`offer_id`) REFERENCES `offer` (`offer_id`),
  ADD CONSTRAINT `coupled_order_ibfk_3` FOREIGN KEY (`pg_fee_id`) REFERENCES `pg_fee` (`pg_fee_id`);

--
-- Constraints for table `decoupled_order`
--
ALTER TABLE `decoupled_order`
  ADD CONSTRAINT `decoupled_order_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`),
  ADD CONSTRAINT `decoupled_order_ibfk_2` FOREIGN KEY (`offer_id`) REFERENCES `offer` (`offer_id`),
  ADD CONSTRAINT `decoupled_order_ibfk_3` FOREIGN KEY (`pg_fee_id`) REFERENCES `pg_fee` (`pg_fee_id`);

--
-- Constraints for table `gcash_order`
--
ALTER TABLE `gcash_order`
  ADD CONSTRAINT `gcash_order_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `offer`
--
ALTER TABLE `offer`
  ADD CONSTRAINT `offer_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);

--
-- Constraints for table `store`
--
ALTER TABLE `store`
  ADD CONSTRAINT `store_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`merchant_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
