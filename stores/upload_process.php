<?php
require_once("../header.php");
require_once("../inc/config.php");

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
        echo "<br><br><h2 style='color:#4caf50;'>Upload complete</h2><br>";
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

function checkForDuplicates($conn, $storeId, $storeName) {
    $stmt = $conn->prepare("SELECT store_id, store_name FROM store WHERE store_id = ? OR store_name = ?");
    $stmt->bind_param("ss", $storeId, $storeName);
    $stmt->execute();
    $result = $stmt->get_result();
    $duplicates = [];
    while ($row = $result->fetch_assoc()) {
        if ($row['store_id'] === $storeId) {
            $duplicates[] = "Store ID '{$storeId}' already exists.";
        }
        if ($row['store_name'] === $storeName) {
            $duplicates[] = "Store Name '{$storeName}' already exists.";
        }
    }
    $stmt->close();
    return $duplicates;
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

function updateActivityHistory($conn, $storeId, $userId) {
    $stmt = $conn->prepare("UPDATE activity_history SET user_id = ? WHERE description LIKE CONCAT('%', ?, '%') AND user_id IS NULL ORDER BY created_at DESC LIMIT 1");
    $stmt->bind_param("ss", $userId, $storeId);
    $stmt->execute();
    $stmt->close();
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

    $duplicateMessages = [];
    $invalidMerchantIds = [];
    $storeIds = [];
    $duplicateStoreIds = [];

    while (($data = fgetcsv($handle)) !== FALSE) {
        $merchantId = $data[1]; 
        $storeId = $data[3];
        $storeName = $data[2]; 

        if (isset($storeIds[$storeId])) {
            if (!isset($duplicateStoreIds[$storeId])) {
                $duplicateStoreIds[$storeId] = [$storeName, $storeIds[$storeId]];
            }
            $duplicateStoreIds[$storeId][] = $storeName;
        } else {
            $storeIds[$storeId] = $storeName;
        }

        $duplicates = checkForDuplicates($conn, $storeId, $storeName);

        if (!empty($duplicates)) {
            $duplicateMessages = array_merge($duplicateMessages, $duplicates);
        }

        if (!checkMerchantExistence($conn, $merchantId) && !in_array("Merchant ID '{$merchantId}' does not exist.", $invalidMerchantIds)) {
            $invalidMerchantIds[] = "Merchant ID '{$merchantId}' does not exist.";
        }
    }

    fclose($handle);

    foreach ($duplicateStoreIds as $storeId => $storeNames) {
        $duplicateMessages[] = "Duplicate Store ID '{$storeId}' in CSV file: " . implode(", ", $storeNames);
    }

    if (!empty($duplicateMessages) || !empty($invalidMerchantIds)) {
        $conn->close();
        $errorMessages = array_merge($duplicateMessages, $invalidMerchantIds);
        displayMessage('error', 'Errors found:<br>' . implode('<br>', $errorMessages));
        exit();
    }

    $handle = fopen($file_tmp, "r");
    fgetcsv($handle); 
    $stmt = $conn->prepare("INSERT INTO store (store_id, merchant_id, store_name, legal_entity_name, store_address, email_address) VALUES (?, ?, ?, ?, ?, ?)");
    $userId = $_SESSION['user_id']; 
    while (($data = fgetcsv($handle)) !== FALSE) {
        $data[4] = empty($data[4]) ? null : $data[4];
        $data[5] = empty($data[5]) ? null : $data[5]; 
        $data[6] = empty($data[6]) ? null : $data[6];
        $stmt->bind_param("ssssss", $data[3], $data[1], $data[2], $data[4], $data[5], $data[6]);
        $stmt->execute();

        updateActivityHistory($conn, $data[1], $userId);
    }

    fclose($handle);
    $stmt->close();
    $conn->close();

    displayMessage('success', 'Upload complete');
} else {
    displayMessage('error', 'No file uploaded');
}
?>
