<?php
require_once("../header.php");
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
?>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../style.css">
    <title>Failed</title>
    <style>
        body {
            background-image: url("../images/bg_booky.png");
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
            border-radius: 10px;
            width: 250px;
            height: 350px;
            padding-top: 70px;
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
            stroke: #f44336;
            fill: none;
        }

        .checkmark__check {
            stroke-dasharray: 48;
            stroke-dashoffset: 48;
            stroke-width: 4;
            stroke-linecap: round;
            stroke-miterlimit: 10;
            stroke: #f44336;
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
            <path class="checkmark__check" fill="none" d="M16 16 36 36 M36 16 16 36"/>
        </svg>
        <h2 style="padding-top:10px;color: #f44336;">Failed to generate report</h2>
        <a href="../store/index.php?merchant_id=<?php echo $merchant_id; ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"><button type="button" class="btn btn-secondary okay-failed">Okay</button></a>
    </div>
    <script>
        setTimeout(function(){
            window.location.href = 'index.php';
        }, 3000);
    </script>
</body>
</html>
