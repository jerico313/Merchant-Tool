<?php
require_once("header.php");
require_once("inc/config.php");

if(isset($_FILES['fileToUpload']['name']) && $_FILES['fileToUpload']['name'] != ''){
    $file_name = $_FILES['fileToUpload']['name'];
    $file_tmp = $_FILES['fileToUpload']['tmp_name'];

    $file_name_parts = explode('.', $_FILES['fileToUpload']['name']);
    $file_ext = strtolower(end($file_name_parts));
    $extensions = array("csv");

    if(in_array($file_ext,$extensions) === false){
        echo "Extension not allowed, please choose a CSV file.";
        exit();
    }

    move_uploaded_file($file_tmp,"uploads/".$file_name);

    // Process CSV file and insert data into MySQL
    $csvFile = "uploads/".$file_name;
    $handle = fopen($csvFile, "r");
    $header = fgetcsv($handle); // Skip header row

    // Prepare MySQL statement
    $stmt = $conn->prepare("INSERT INTO orders (order_id, transaction_date, customer_name, customer_id, payment_status, payment, merchant_name, merchant_id, store_name, store_id, promo_codes, promo_type, claim_id, gross_sale, voucher_price, total_actual_sales) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    while (($data = fgetcsv($handle)) !== FALSE) {
        // Remove commas from numeric values
        $data[13] = str_replace(',', '', $data[13]); // gross_sale
        $data[14] = str_replace(',', '', $data[14]); // voucher_price
        $data[15] = str_replace(',', '', $data[15]); // total_actual_sales

        $stmt->bind_param("ssssssssssssssss", $data[3], $data[0], $data[1], $data[2], $data[4], $data[5], $data[6], $data[7], $data[8], $data[9], $data[10], $data[11], $data[12], $data[13], $data[14], $data[15]);
        $stmt->execute();
    }

    fclose($handle);
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
        <h2 style="padding-top:10px;color: #4caf50;">Successfully uploaded!</h2>
        <a href="order.php"><button type="button" class="btn btn-secondary okay">Okay</button></a>
    </div>
    <script>
        setTimeout(function(){
            window.location.href = 'order.php';
        }, 3000); // Delay for 3 seconds (3000 milliseconds)
    </script>
</body>
</html>


<?php
} else {
  echo "No file uploaded.";
}
?>
