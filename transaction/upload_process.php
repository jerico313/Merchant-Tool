<?php
require_once ("../header.php");
require_once ("../inc/config.php");

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
            padding: 20px; /* Increased padding */
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
            font-size: 14px; /* Adjusted font size */
            text-align: left; /* Left-align list items */
            margin-top: 10px;
            padding-left: 0; /* Remove default padding */
            list-style-type: none; /* Remove bullet points */
        }
        .error-list li {
            margin-bottom: 5px; /* Adjust spacing between list items */
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

    // Display success message
    if ($type === 'success') {
        echo "<br><h2 style='color:#4caf50;'>Successfully Uploaded</h2><br>";
    }

    // If the message is an error and contains a list, format the list accordingly
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

function checkForDuplicates($conn, $transactionId)
{
    $stmt = $conn->prepare("SELECT transaction_id FROM transaction WHERE transaction_id = ?");
    $stmt->bind_param("s", $transactionId);
    $stmt->execute();
    $result = $stmt->get_result();
    $exists = $result->num_rows > 0;
    $stmt->close();
    return $exists ? ["Transaction ID '{$transactionId}' already exists."] : [];
}

function checkStoreExistence($conn, $storeId)
{
    $stmt = $conn->prepare("SELECT * FROM store WHERE store_id = ?");
    $stmt->bind_param("s", $storeId);
    $stmt->execute();
    $result = $stmt->get_result();
    $exists = $result->num_rows > 0;
    $stmt->close();
    return $exists;
}

function checkPromoExistence($conn, $promoCode)
{
    $stmt = $conn->prepare("SELECT * FROM promo WHERE promo_code = ?");
    $stmt->bind_param("s", $promoCode);
    $stmt->execute();
    $result = $stmt->get_result();
    $exists = $result->num_rows > 0;
    $stmt->close();
    return $exists;
}

function updateActivityHistory($conn, $customerId, $userId) {
    $stmt = $conn->prepare("UPDATE activity_history SET user_id = ? WHERE description LIKE CONCAT('%', ?, '%') AND user_id IS NULL ORDER BY created_at DESC LIMIT 1");
    $stmt->bind_param("ss", $userId, $customerId);
    $stmt->execute();
    $stmt->close();
}

function convertDateFormat($dateString)
{
    $date = DateTime::createFromFormat('F d, Y h:iA', $dateString);
    return $date->format('Y-m-d H:i:s');
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
    fgetcsv($handle); // Skip header row

    $duplicateMessages = [];
    $invalidStoreIds = [];
    $invalidPromoCodes = [];
    $transactionIds = [];
    $duplicateTransactionIds = [];

    while (($data = fgetcsv($handle)) !== FALSE) {
        $storeId = $data[3]; // Assuming data[3] is store_id
        $transactionId = $data[7]; // Assuming data[7] is transaction_id
        $promoCode = $data[6]; // Assuming data[6] is promo_code

        // Check for duplicate transaction IDs in the CSV file itself
        if (isset($transactionIds[$transactionId])) {
            if (!isset($duplicateTransactionIds[$transactionId])) {
                $duplicateTransactionIds[$transactionId] = [$transactionId, $transactionIds[$transactionId]];
            }
            $duplicateTransactionIds[$transactionId][] = $transactionId;
        } else {
            $transactionIds[$transactionId] = $transactionId;
        }

        // Check for duplicates in the database
        $duplicates = checkForDuplicates($conn, $transactionId);

        if (!empty($duplicates)) {
            $duplicateMessages = array_merge($duplicateMessages, $duplicates);
        }

        // Check if store ID exists
        if (!checkStoreExistence($conn, $storeId) && !in_array("Store ID '{$storeId}' does not exist.", $invalidStoreIds)) {
            $invalidStoreIds[] = "Store ID '{$storeId}' does not exist.";
        }

        // Check if promo code exists
        if (!checkPromoExistence($conn, $promoCode) && !in_array("Promo Code '{$promoCode}' does not exist.", $invalidPromoCodes)) {
            $invalidPromoCodes[] = "Promo Code '{$promoCode}' does not exist.";
        }
    }

    fclose($handle);

    // Add duplicate transaction IDs from the CSV file to the duplicate messages
    foreach ($duplicateTransactionIds as $transactionId => $transactionIds) {
        $duplicateMessages[] = "Duplicate Transaction ID '{$transactionId}' in CSV file: " . implode(", ", $transactionIds);
    }

    if (!empty($duplicateMessages) || !empty($invalidStoreIds) || !empty($invalidPromoCodes)) {
        $conn->close();
        $errorMessages = array_merge($duplicateMessages, $invalidStoreIds, $invalidPromoCodes);
        displayMessage('error', 'Errors found:<br>' . implode('<br>', $errorMessages));
        exit();
    }

    // If no duplicates and all store IDs and promo codes are valid, proceed with inserting into the database
    $handle = fopen($file_tmp, "r");
    fgetcsv($handle); // Skip header row again

    $stmt1 = $conn->prepare("INSERT INTO transaction (transaction_id, store_id, promo_code, customer_id, customer_name, transaction_date, gross_amount, discount, amount_discounted, amount_paid, payment, comm_rate_base, bill_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $userId = $_SESSION['user_id']; 
    while (($data = fgetcsv($handle)) !== FALSE) {
        $data[4] = empty($data[4]) ? null : $data[4]; // Convert blank customer_name to null
        $transaction_date = convertDateFormat($data[8]);
        $data[9] = str_replace(',', '', $data[9]); // gross_amount
        $data[10] = str_replace(',', '', $data[10]); // discount
        $data[11] = str_replace(',', '', $data[11]); // amount_discounted
        $data[12] = str_replace(',', '', $data[12]); // amount_paid
        $data[13] = ($data[13] = str_replace('"', '', $data[13])) === '' ? null : $data[13]; //payment

        // Bind and execute for the transaction table
        $stmt1->bind_param("sssssssssssss", $data[7], $data[3], $data[6], $data[5], $data[4], $transaction_date, $data[9], $data[10], $data[11], $data[12], $data[13], $data[14], $data[15]);
        $stmt1->execute();
        
        updateActivityHistory($conn, $data[5], $userId);
    }

    fclose($handle);
    $stmt1->close();
    $conn->close();

    displayMessage('success', 'Successfully uploaded!');
} else {
    displayMessage('error', 'No file uploaded.');
}
?>