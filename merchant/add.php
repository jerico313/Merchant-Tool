<?php
require_once("../header.php");
require_once '../inc/config.php';

$conn = new mysqli($db_host, $db_user, $db_password, $db_name);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $stmt = $conn->prepare("INSERT INTO merchant (merchant_id, merchant_name, merchant_partnership_type, legal_entity_name, business_address, email_address, sales, account_manager) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssss", $merchant_id, $merchant_name, $merchant_partnership_type, $legal_entity_name, $business_address, $email_address, $sales, $account_manager);

    foreach ($_POST['merchant_id'] as $key => $value) {
        $merchant_id = $_POST['merchant_id'][$key];
        $merchant_name = $_POST['merchant_name'][$key];
        $merchant_partnership_type = empty($_POST['merchant_partnership_type'][$key]) ? NULL : $_POST['merchant_partnership_type'][$key];
        $legal_entity_name = empty($_POST['legal_entity_name'][$key]) ? NULL : $_POST['legal_entity_name'][$key];
        $business_address = empty($_POST['business_address'][$key]) ? NULL : $_POST['business_address'][$key];
        $email_address = empty($_POST['email_address'][$key]) ? NULL : $_POST['email_address'][$key];
        $sales = empty($_POST['sales'][$key]) ? NULL : $_POST['sales'][$key];
        $account_manager = empty($_POST['account_manager'][$key]) ? NULL : $_POST['account_manager'][$key];
        $stmt->execute();

        $update_stmt = $conn->prepare("
            UPDATE activity_history
            SET user_id = ?
            WHERE (user_id IS NULL OR user_id = '')
            AND description LIKE CONCAT('%merchant_name: ', ?, '%')
            AND activity_type = 'Add'
        ");

        $user_id = $_SESSION['user_id']; 

        $update_stmt->bind_param("ss", $user_id, $merchant_name);
        $update_stmt->execute();
        $update_stmt->close();
    }

    $stmt->close();
}

$conn->close();
?>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../style.css">
    <title>Upload Success</title>
    <style>
        body {
            background-image: url("../images/bg_booky.png");
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
        <a href="index.php"><button type="button" class="btn btn-secondary okay">Okay</button></a>
    </div>
    <script>
        setTimeout(function(){
            window.location.href = 'index.php';
        }, 3000);
    </script>
</body>
</html>
