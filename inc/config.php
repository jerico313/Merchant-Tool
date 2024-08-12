<?php
$db_host = "localhost"; 
$db_user = "root"; 
$db_password = ""; 
$db_name = "leadgen_db";

$conn = mysqli_connect($db_host, $db_user, $db_password, $db_name);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

global $connection;
?>