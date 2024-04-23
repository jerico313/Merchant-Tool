<?php
// Database configuration
$db_host = "localhost"; // Replace with your database host
$db_user = "root"; // Replace with your database username
$db_password = ""; // Replace with your database password
$db_name = "pnr";

// Create a database connection
$conn = mysqli_connect($db_host, $db_user, $db_password, $db_name);

// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

global $connection;
?>