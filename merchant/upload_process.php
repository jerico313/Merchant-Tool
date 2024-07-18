<?php
require_once("../header.php");
require_once("../inc/config.php");

function displayMessage($type, $message) {
    $color = $type === 'error' ? '#f44336' : '#4caf50';
    $icon = $type === 'error' ? 'error-icon' : 'checkmark';
    $path = $type === 'error' ? '<line x1="16" y1="16" x2="36" y2="36"/><line x1="36" y1="16" x2="16" y2="36"/>' : '<path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>';
    echo <<<HTML
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../style.css">
    <title>Message</title>
    <style>
        body { 
            background-image: url("../images/bg_booky.png"); 
            background-position: center; 
            background-repeat: no-repeat; 
            background-size: cover; 
            background-attachment: fixed; 
        }
        .container { 
   
            text-align: center; 
            margin-top:50px;
            border: solid #fff 2px; 
            border-radius: 10px; 
            width: 500px;
            height: auto; 
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
    </style>
</head>
<body>
    <div class="container">
        <svg class="$icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
            <circle cx="26" cy="26" r="25"/>
            $path
        </svg>
HTML;

    // If the message is an error and contains a list, format the list accordingly
    if ($type === 'error' && strpos($message, '<br>') !== false) {
        echo '<ul class="error-list">';
        $errors = explode('<br>', $message);
        foreach ($errors as $error) {
            echo "<li>$error</li>";
        }
        echo '</ul>';
    }

    echo <<<HTML
        <a href="index.php"><button type="button" class="btn btn-secondary okay">Okay</button></a>
    </div>
</body>
</html>
HTML;
}

function checkForDuplicates($conn, $merchantId, $merchantName) {
    $stmt = $conn->prepare("SELECT merchant_id, merchant_name FROM merchant WHERE merchant_id = ? OR merchant_name = ?");
    $stmt->bind_param("ss", $merchantId, $merchantName);
    $stmt->execute();
    $result = $stmt->get_result();
    $duplicates = [];
    while ($row = $result->fetch_assoc()) {
        if ($row['merchant_id'] === $merchantId) {
            $duplicates[] = "Merchant ID '{$merchantId}' already exists.";
        }
        if ($row['merchant_name'] === $merchantName) {
            $duplicates[] = "Merchant Name '{$merchantName}' already exists.";
        }
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

    $duplicateMessages = [];

    while (($data = fgetcsv($handle)) !== FALSE) {
        $duplicates = checkForDuplicates($conn, $data[1], $data[0]);
        if (!empty($duplicates)) {
            $duplicateMessages = array_merge($duplicateMessages, $duplicates);
        }
    }

    fclose($handle);

    if (!empty($duplicateMessages)) {
        $conn->close();
        displayMessage('error', 'Errors found:<br>' . implode('<br>', $duplicateMessages));
        exit();
    }

    // If no duplicates, proceed with inserting into database
    $handle = fopen($file_tmp, "r");
    fgetcsv($handle); // Skip header row again
    $stmt = $conn->prepare("INSERT INTO merchant (merchant_id, merchant_name, merchant_partnership_type, legal_entity_name, business_address, email_address) VALUES (?, ?, ?, ?, ?, ?)");
    while (($data = fgetcsv($handle)) !== FALSE) {
        $stmt->bind_param("ssssss", $data[1], $data[0], $data[2], $data[3], $data[4], $data[5]);
        $stmt->execute();
    }

    fclose($handle);
    $stmt->close();
    $conn->close();

    displayMessage('success', 'Successfully uploaded!');
} else {
    displayMessage('error', 'No file uploaded.');
}
?>
