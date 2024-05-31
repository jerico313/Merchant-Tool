<?php
// Include the configuration file
require_once("header.php");
require_once 'inc/config.php';

// Create a database connection
$conn = new mysqli($db_host, $db_user, $db_password, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Prepare and bind SQL statement
    $stmt = $conn->prepare("INSERT INTO merchant (merchant_id, merchant_name, merchant_partnership_type, merchant_type, business_address, email_address) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssss", $merchant_id, $merchant_name, $merchant_partnership_type, $merchant_type, $business_address, $email_address);

    // Set parameters and execute
    foreach ($_POST['merchant_id'] as $key => $value) {
        $merchant_id = $_POST['merchant_id'][$key];
        $merchant_name = $_POST['merchant_name'][$key];
        $merchant_partnership_type = $_POST['merchant_partnership_type'][$key];
        $merchant_type = $_POST['merchant_type'][$key];
        $business_address = $_POST['business_address'][$key];
        $email_address = $_POST['email_address'][$key];
        $stmt->execute();
    }

    // Close statement
    $stmt->close();
}

// Close connection
$conn->close();
?>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="style.css">
    <title>Upload Success</title>
    <style>
        body {
            background-image: url("images/bg_booky.png");
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            background-attachment: fixed;
        }

        .container {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            border: solid #fff 2px;
            border-radius:10px;
            width:250px;
            height:350px;
            padding-top:70px;
            backdrop-filter: blur(16px) saturate(180%);
            -webkit-backdrop-filter: blur(16px) saturate(180%);
            background-color: rgba(255, 255, 255, 0.40);
            border-radius: 12px;
            border: 1px solid rgba(209, 213, 219, 0.3);
            box-shadow: rgba(0, 0, 0, 0.1) 0px 4px 6px -1px, rgba(0, 0, 0, 0.06) 0px 2px 4px -1px;
        }
        .checkmark {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: block;
            margin: 0 auto;
        }
        .checkmark__circle {
            stroke-width: 4;
            stroke-miterlimit: 10;
            stroke: #4caf50;
            fill: none;
        }
        .checkmark__check {
            stroke-dasharray: 48;
            stroke-dashoffset: 48;
            stroke-width: 4;
            stroke-linecap: round;
            stroke-miterlimit: 10;
            stroke: #4caf50;
            fill: none;
            animation: draw 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
        }
        @keyframes draw {
            0% {
                stroke-dashoffset: 48;
            }
            100% {
                stroke-dashoffset: 0;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
            <circle class="checkmark__circle" cx="26" cy="26" r="25"/>
            <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
        </svg>
        <h2 style="padding-top:10px;color: #4caf50;">Successfully Added!</h2>
        <a href="merchant.php"><button type="button" class="btn btn-secondary okay">Okay</button></a>
    </div>
    <script>
        setTimeout(function(){
            window.location.href = 'merchant.php';
        }, 3000); // Delay for 3 seconds (3000 milliseconds)
    </script>
</body>
</html>
