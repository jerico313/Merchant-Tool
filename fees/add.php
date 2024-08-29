<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

require_once("../header.php");
require_once '../inc/config.php';
require_once '../vendor/autoload.php'; 

use Ramsey\Uuid\Uuid;

$conn = new mysqli($db_host, $db_user, $db_password, $db_name);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $stmt = $conn->prepare("INSERT INTO fee (fee_id, merchant_id, paymaya_credit_card, gcash, gcash_miniapp, paymaya, maya_checkout, maya, lead_gen_commission, commission_type, cwt_rate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssssssss", $fee_id, $merchant_id, $paymaya_creditcard, $gcash, $gcash_miniapp, $paymaya, $paymaya_creditcard, $paymaya_creditcard, $leadgen_commission, $commission_type, $cwt_rate);

    foreach ($_POST['merchant_id'] as $key => $value) {
        $fee_id = Uuid::uuid4()->toString();
        $merchant_id = $_POST['merchant_id'][$key];
        $paymaya_creditcard = $_POST['paymaya_creditcard'][$key];
        $gcash = $_POST['gcash'][$key];
        $gcash_miniapp = $_POST['gcash_miniapp'][$key];
        $paymaya = $_POST['paymaya'][$key];
        $leadgen_commission = $_POST['leadgen_commission'][$key];
        $commission_type = $_POST['commission_type'][$key];
        $cwt_rate = $_POST['cwt_rate'][$key];
        $stmt->execute();

        $update_stmt = $conn->prepare("
            UPDATE activity_history
            SET user_id = ?
            WHERE (user_id IS NULL OR user_id = '')
            AND description LIKE CONCAT('%merchant_id: ', ?, '%')
        ");

        $user_id = $_SESSION['user_id']; 

        $update_stmt->bind_param("ss", $user_id, $merchant_id);
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
        <a href="index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"><button type="button" class="btn btn-secondary okay">Okay</button></a>
    </div>
    <script>
        setTimeout(function(){
            window.location.href = 'index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>';
        }, 3000);
    </script>
</body>
</html>
