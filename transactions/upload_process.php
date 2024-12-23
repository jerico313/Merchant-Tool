<?php
require_once("../header.php");
require_once("../inc/config.php");
set_time_limit(1200); 

function displayMessage($type, $message)
{
    $color = $type === 'error' ? '#f44336' : '#4caf50';
    $icon = $type === 'error' ? 'error-icon' : 'checkmark';
    $path = $type === 'error' ? '<line x1="16" y1="16" x2="36" y2="36"/><line x1="36" y1="16" x2="16" y2="36"/>' : '<path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>';
    $containerWidth = $type === 'success' ? '250px' : '500px';
    $containerHeight = $type === 'success' ? '300px' : 'auto';
    echo <<<HTML
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../style.css">
    <title>Message</title>
    <style>
        body { 
            background-image: url("../images/bg_booky.png"); 
        }
        .container { 
            text-align: center; 
            margin-top:50px;
            margin-bottom:30px;
            border: solid #fff 2px; 
            border-radius: 10px; 
            width: $containerWidth;
            height: $containerHeight; 
            padding: 20px;
            backdrop-filter: blur(16px) saturate(180%); 
            -webkit-backdrop-filter: blur(16px) saturate(180%); 
            background-color: rgba(255, 255, 255, 0.40); 
            border: 1px solid rgba(209, 213, 219, 0.3); 
            box-shadow: rgba(0, 0, 0, 0.1) 0px 4px 6px -1px, rgba(0, 0, 0, 0.06) 0px 2px 4px -1px; 
        }
        .$icon { 
            width: 80px; 
            height: 80px; 
            border-radius: 50%;
            display: block; 
            margin: 0 auto; 
        }
        .$icon circle { 
            stroke-width: 4; 
            stroke-miterlimit: 10; 
            stroke: $color; 
            fill: none; 
        }
        .$icon line, .$icon path { 
            stroke-dasharray: 48;
            stroke-dashoffset: 48;
            stroke-width: 4;
            stroke-linecap: round;
            stroke-miterlimit: 10;
            stroke: $color; 
            fill: none; 
            animation: draw 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards; 
        }
        @keyframes draw { 
            0% { stroke-dashoffset: 48; } 
            100% { stroke-dashoffset: 0; } 
        }
        .error-list {
            font-size: 14px; 
            text-align: left; 
            margin-top: 10px;
            padding-left: 0; 
            list-style-type: none; 
        }
        .error-list li {
            margin-bottom: 5px; 
        }
        #okay{
        display: inline-block;
        background-color: $color;
        color:#fff;
        border:solid $color 2px;
        width:150px;
        border-radius: 20px;
        cursor: pointer;
        margin-top:30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <svg class="$icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
            <circle cx="26" cy="26" r="25"/>
            $path
        </svg>
HTML;

    if ($type === 'success') {
        echo "<br><h2 style='color:#4caf50;'>Upload complete</h2><br>";
    }

    if ($type === 'error' && strpos($message, '<br>') !== false) {
        echo "<br><h2 style='color:#f44336;'>Error</h2>";
        echo '<ul class="error-list">';
        $errors = explode('<br>', $message);
        foreach ($errors as $error) {
            echo "<li>$error</li>";
        }
        echo '</ul>';
    }

    echo <<<HTML
        <a href="index.php"><button type="button" class="btn btn-secondary okay" id="okay">Okay</button></a>
    </div>
</body>
</html>
HTML;
}

function updateActivityHistory($conn, $customerId, $userId) {
    $stmt = $conn->prepare("UPDATE activity_history SET user_id = ? WHERE description LIKE CONCAT('%', ?, '%') AND user_id IS NULL ORDER BY created_at DESC LIMIT 1");
    $stmt->bind_param("ss", $userId, $customerId);
    $stmt->execute();
    $stmt->close();
}

function convertDateFormat($dateString)
{
    // Check if the string contains a time part and also if it has an extra comma
    if (strpos($dateString, ',') !== false && strpos($dateString, ':') !== false) {
        // If there is an extra comma, remove it and parse with date and time
        $dateString = str_replace(', ', ' ', $dateString); // Remove the extra comma
        $date = DateTime::createFromFormat('F d Y h:iA', $dateString);
    } elseif (strpos($dateString, ':') !== false) {
        // Parse with date and time if colon is present (without extra comma)
        $date = DateTime::createFromFormat('F d, Y h:iA', $dateString);
    } else {
        // Parse date only and set default time to 00:00:00 if no time is present
        $date = DateTime::createFromFormat('F d, Y', $dateString);
        if ($date) {
            $date->setTime(0, 0, 0);
        }
    }

    return $date ? $date->format('Y-m-d H:i:s') : false;
}

function executeBatchInsert($stmt, $data, $conn, $userId) {
    foreach ($data as $row) {
        // Ensure each row is an array
        if (!is_array($row)) {
            throw new Exception("Each row in \$data must be an array.");
        }

        // Bind parameters
        $stmt->bind_param("sssssssssssssss", ...$row);
        $stmt->execute();

        // Call updateActivityHistory after each row is inserted
        updateActivityHistory($conn, $row[5], $userId);
    }
}

if (isset($_FILES['fileToUpload']['name']) && $_FILES['fileToUpload']['name'] != '') {
    $file_tmp = $_FILES['fileToUpload']['tmp_name'];
    $file_ext = strtolower(pathinfo($_FILES['fileToUpload']['name'], PATHINFO_EXTENSION));

    if ($file_ext !== 'csv') {
        displayMessage('error', 'Extension not allowed, please choose a CSV file.');
        exit();
    }

    $conn = new mysqli($db_host, $db_user, $db_password, $db_name);
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $handle = fopen($file_tmp, "r");
    fgetcsv($handle); 

    // Load all transaction_ids, store_ids, and promo_codes in memory to avoid multiple DB hits
    $existingTransactionIds = array_column($conn->query("SELECT transaction_id FROM transaction")->fetch_all(MYSQLI_ASSOC), 'transaction_id');
    $existingStoreIds = array_column($conn->query("SELECT store_id FROM store")->fetch_all(MYSQLI_ASSOC), 'store_id');
    $existingPromoCodes = array_column($conn->query("SELECT promo_code FROM promo")->fetch_all(MYSQLI_ASSOC), 'promo_code');

    $validationErrors = [];
    $csvTransactionIds = [];
    $validPayment = ['"paymaya_credit_card"', '"gcash"', '"gcash_miniapp"', '"paymaya"', '"maya"', '"maya_checkout"'];
    $validBillStatus = ['PRE-TRIAL', 'BILLABLE', 'NOT BILLABLE'];
    $rowsProcessed = 0;

    while (($data = fgetcsv($handle)) !== FALSE) {
        $storeId = $data[3]; 
        $promoCode = $data[6]; 
        $voucherType = $data[7];
        $promoGroup = $data[8];
        $transactionId = strtolower($data[9]);
        $payment = $data[15];
        $billStatus = $data[17];

        // Check for duplicates within the CSV file
        if (in_array($transactionId, $csvTransactionIds)) {
            $validationErrors[] = "Duplicate Transaction ID '{$transactionId}' found in the CSV file.";
        }
        $csvTransactionIds[] = $transactionId;

        // Check if transaction ID already exists in the database
        if (in_array($transactionId, $existingTransactionIds)) {
            $validationErrors[] = "Transaction ID '{$transactionId}' already exists in the database.";
        }

        // Check if store ID exists
        if (!in_array($storeId, $existingStoreIds)) {
            $validationErrors[] = "Store ID '{$storeId}' does not exist.";
        }

        // Check if promo code exists (if provided)
        if ($promoCode && !in_array($promoCode, $existingPromoCodes)) {
            $validationErrors[] = "Promo Code '{$promoCode}' does not exist.";
        }

        // Validate fields [6], [7], and [8]
        if (!empty($promoCode) && (!empty($voucherType) || !empty($promoGroup))) {
            $validationErrors[] = "Transaction ID '{$transactionId}': Only promo_code should be filled if it's present.";
        } elseif (empty($promoCode) && (empty($voucherType) || empty($promoGroup))) {
            $validationErrors[] = "Transaction ID '{$transactionId}': Both voucher_type and promo_group are required if promo_code is empty.";
        }

        // Check payment
        if (!empty($payment) && !in_array(strtolower($payment), $validPayment)) {
            $validationErrors[] = "Invalid Payment '{$payment}' for Transaction ID '{$transactionId}'.";
        } 

        // Check billStatus
        if (empty($billStatus)) {
            $validationErrors[] = "Bill Status is empty for Transaction ID '{$transactionId}'.";
        } else if (!in_array(strtoupper($billStatus), $validBillStatus)) {
            $validationErrors[] = "Invalid Bill Status '{$billStatus}' for Transaction ID '{$transactionId}'.";
        }
    }

    fclose($handle);

    if (!empty($validationErrors)) {
        $conn->close();

        // Count total number of errors
        $totalErrors = count($validationErrors);

        // Display the error message
        displayMessage('error', "Errors found: {$totalErrors}<br>" . implode('<br>', $validationErrors));
        exit();
    }

    $handle = fopen($file_tmp, "r");
    fgetcsv($handle);

    $batchInsertData = [];

    $stmt1 = $conn->prepare("INSERT INTO transaction (transaction_id, store_id, promo_code, no_voucher_type, no_promo_group, customer_id, customer_name, transaction_date, gross_amount, discount, amount_discounted, amount_paid, payment, comm_rate_base, bill_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $userId = $_SESSION['user_id'];
    while (($data = fgetcsv($handle)) !== FALSE) {
        $data[4] = empty($data[4]) ? null : $data[4];
        $data[5] = (substr($data[5], 0, 1) !== '"' || substr($data[5], -1) !== '"') ? '"' . $data[5] . '"' : $data[5];
        $data[6] = empty($data[6]) ? null : $data[6];
        $data[7] = empty($data[7]) ? null : $data[7];
        $data[8] = empty($data[8]) ? null : $data[8];
        $data[9] = strtolower($data[9]);
        $transaction_date = convertDateFormat($data[10]);
        $data[11] = str_replace(',', '', $data[11]);
        $data[12] = str_replace(',', '', $data[12]);
        $data[13] = str_replace(',', '', $data[13]);
        $data[14] = str_replace(',', '', $data[14]);
        $data[15] = ($data[15] = str_replace('"', '', $data[15])) === '' ? null : $data[15];

        //Accumulate data for batch insert
        $batchInsertData[] = [
            $data[9], $data[3], $data[6], $data[7], $data[8], $data[5], $data[4],
            $transaction_date, $data[11], $data[12], $data[13], $data[14], $data[15], $data[16], $data[17]
        ];

        // Insert in batches and commit every 200 rows
        if (count($batchInsertData) >= 200) {
            $conn->begin_transaction(); // Start a new transaction
            try {
                executeBatchInsert($stmt1, $batchInsertData, $conn, $userId);
                $conn->commit(); // Commit the transaction
                $batchInsertData = []; // Clear batch
            } catch (Exception $e) {
                $conn->rollback(); // Rollback on error
                displayMessage('error', 'Failed to insert data for batch: ' . $e->getMessage());
                break; // Exit the loop on error
            }
        }

        // $stmt1->bind_param("sssssssssssssss", $data[9], $data[3], $data[6], $data[7], $data[8], $data[5], $data[4], $transaction_date, $data[11], $data[12], $data[13], $data[14], $data[15], $data[16], $data[17]);
        // $stmt1->execute();

        // updateActivityHistory($conn, $data[5], $userId);
    }

    // Insert any remaining data in the last batch and commit
    if (!empty($batchInsertData)) {
        $conn->begin_transaction(); // Start a new transaction
        try {
            executeBatchInsert($stmt1, $batchInsertData, $conn, $userId);
            $conn->commit(); // Commit the transaction
        } catch (Exception $e) {
            $conn->rollback(); // Rollback on error
            displayMessage('error', 'Failed to insert data for remaining batch: ' . $e->getMessage());
        }
    }

    fclose($handle);
    $stmt1->close();
    $conn->close();

    displayMessage('success', 'Upload complete');
} else {
    displayMessage('error', 'No file uploaded');
}
?>