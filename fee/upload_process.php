<?php
require_once("../header.php");
require_once("../inc/config.php");
require_once '../vendor/autoload.php'; // Include the Composer autoload file

use Ramsey\Uuid\Uuid;

function displayMessage($type, $message) {
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

function checkMerchantExistence($conn, $merchantId) {
    $stmt = $conn->prepare("SELECT * FROM merchant WHERE merchant_id = ?");
    $stmt->bind_param("s", $merchantId);
    $stmt->execute();
    $result = $stmt->get_result();
    $exists = $result->num_rows > 0;
    $stmt->close();
    return $exists;
}

function checkForDuplicates($conn, $merchantId) {
    $stmt = $conn->prepare("SELECT merchant_id FROM fee WHERE merchant_id = ?");
    $stmt->bind_param("s", $merchantId);
    $stmt->execute();
    $result = $stmt->get_result();
    $duplicates = [];
    if ($result->num_rows > 0) {
        $duplicates[] = "Merchant ID '{$merchantId}' already exists in the fee table.";
    }
    $stmt->close();
    return $duplicates;
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

    $invalidMerchantIds = [];
    $merchantIds = [];
    $duplicateMerchantIds = [];

    while (($data = fgetcsv($handle)) !== FALSE) {
        $merchantId = $data[1]; // Assuming data[1] is merchant_id

        // Check for duplicate merchant IDs in the CSV file itself
        if (isset($merchantIds[$merchantId])) {
            if (!isset($duplicateMerchantIds[$merchantId])) {
                $duplicateMerchantIds[$merchantId] = [$merchantIds[$merchantId]];
            }
            $duplicateMerchantIds[$merchantId][] = $merchantId;
        } else {
            $merchantIds[$merchantId] = $merchantId;
        }

        // Check if merchant ID exists in the database
        if (!checkMerchantExistence($conn, $merchantId)) {
            $invalidMerchantIds[] = "Merchant ID '{$merchantId}' does not exist.";
        }

        // Check for duplicates in the fee table
        $duplicates = checkForDuplicates($conn, $merchantId);
        if (!empty($duplicates)) {
            $invalidMerchantIds = array_merge($invalidMerchantIds, $duplicates);
        }
    }

    fclose($handle);

    // Add duplicate merchant IDs from the CSV file to the invalid messages
    foreach ($duplicateMerchantIds as $merchantId => $merchantIds) {
        $invalidMerchantIds[] = "Duplicate Merchant ID '{$merchantId}' in CSV file.";
    }

    if (!empty($invalidMerchantIds)) {
        $conn->close();
        displayMessage('error', 'Errors found:<br>' . implode('<br>', $invalidMerchantIds));
        exit();
    }

    $handle = fopen($file_tmp, "r");
    fgetcsv($handle); // Skip header row again

    $stmt1 = $conn->prepare("INSERT INTO fee (fee_id, merchant_id, paymaya_credit_card, gcash, gcash_miniapp, paymaya, maya_checkout, maya, lead_gen_commission, commission_type, cwt_rate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    while (($data = fgetcsv($handle)) !== FALSE) {
        $fee_id = Uuid::uuid4()->toString();
        $stmt1->bind_param("sssssssssss", $fee_id, $data[1], $data[4], $data[5], $data[6], $data[7], $data[8], $data[9], $data[10], $data[11], $data[12]);
        $stmt1->execute();
    }

    fclose($handle);
    $stmt1->close();
    $conn->close();

    displayMessage('success', 'Successfully uploaded!');
} else {
    displayMessage('error', 'No file uploaded.');
}
?>
