<?php
// Include the configuration file
require_once("../header.php");
require_once '../inc/config.php';
$userId = $_SESSION['user_id']; 
// Create a database connection
$conn = new mysqli($db_host, $db_user, $db_password, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$error_message = ''; // Variable to store error messages

// Handle form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Prepare SQL statement to check if a record exists
    $checkStmt = $conn->prepare("SELECT COUNT(*) FROM merchant WHERE merchant_id = ? OR merchant_name = ?");
    
    // Prepare SQL statement for insertion
    $insertStmt = $conn->prepare("INSERT INTO merchant (merchant_id, merchant_name, merchant_partnership_type, legal_entity_name, business_address, email_address, sales, account_manager) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

    // Bind parameters for insertion
    $insertStmt->bind_param("ssssssss", $merchant_id, $merchant_name, $merchant_partnership_type, $legal_entity_name, $business_address, $email_address, $sales, $account_manager);

    // Check if 'sales' or 'account_manager' are empty and set them to NULL
    foreach ($_POST['merchant_id'] as $key => $value) {
        $merchant_id = $_POST['merchant_id'][$key];
        $merchant_name = $_POST['merchant_name'][$key];
        $merchant_partnership_type = empty($_POST['merchant_partnership_type'][$key]) ? NULL : $_POST['merchant_partnership_type'][$key];
        $legal_entity_name = empty($_POST['legal_entity_name'][$key]) ? NULL : $_POST['legal_entity_name'][$key];
        $business_address = empty($_POST['business_address'][$key]) ? NULL : $_POST['business_address'][$key];
        $email_address = empty($_POST['email_address'][$key]) ? NULL : $_POST['email_address'][$key];
        $sales = empty($_POST['sales'][$key]) ? NULL : $_POST['sales'][$key];
        $account_manager = empty($_POST['account_manager'][$key]) ? NULL : $_POST['account_manager'][$key];
        
        // Check if the record already exists
        $checkStmt->bind_param("ss", $merchant_id, $merchant_name);
        $checkStmt->execute();
        $checkStmt->bind_result($count);
        $checkStmt->fetch();
        $checkStmt->free_result(); // Clear the result set
        
        if ($count > 0) {
            // Record already exists
            $error_message = "Error: Record with ID '$merchant_id' or Name '$merchant_name' already exists.";
            break;
        } else {
            // Record does not exist, proceed with the insertion
            if (!$insertStmt->execute()) {
                $error_message = "Error: " . $insertStmt->error;
                break;
            }
        }
    }

    // Close statements
    $checkStmt->close();
    $insertStmt->close();
}

// Close connection
$conn->close();
?>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../style.css">
    <title>Upload Result</title>
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
        .checkmark, .error-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: block;
            margin: 0 auto;
        }
        .checkmark__circle, .error-icon__circle {
            stroke-width: 4;
            stroke-miterlimit: 10;
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
        .error-icon__check {
            stroke-dasharray: 48;
            stroke-dashoffset: 48;
            stroke-width: 4;
            stroke-linecap: round;
            stroke-miterlimit: 10;
            stroke: #f44336;
            fill: none;
            animation: drawError 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
        }
        @keyframes draw {
            0% {
                stroke-dashoffset: 48;
            }
            100% {
                stroke-dashoffset: 0;
            }
        }
        @keyframes drawError {
            0% {
                stroke-dashoffset: 48;
            }
            100% {
                stroke-dashoffset: 0;
            }
        }
        .error {
            color: #f44336; /* Red color for error message */
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
    <?php if ($error_message): ?>
            <svg class="error-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                <circle class="error-icon__circle" cx="26" cy="26" r="25" stroke="#f44336"/>
                <path class="error-icon__check" fill="none" d="M14 14l24 24M38 14L14 38" stroke="#f44336"/>
            </svg>
            <p class="error" style="background-color:transparent;"><?php echo htmlspecialchars($error_message); ?></p>
            <a href="index.php"><button type="button" class="btn btn-secondary okay-failed" style="margin-top:70px;">Okay</button></a>
            <?php else: ?>
            <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                <circle class="checkmark__circle" cx="26" cy="26" r="25" stroke="#4caf50"/>
                <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8" stroke="#4caf50"/>
            </svg>
            <h2 style="padding-top:10px;color: #4caf50;">Successfully Added!</h2>
            <a href="index.php"><button type="button" class="btn btn-secondary okay">Okay</button></a>
        <?php endif; ?>
    </div>
    <script>
        setTimeout(function(){
            window.location.href = 'index.php';
        }, 3000); // Delay for 3 seconds (3000 milliseconds)
    </script>
</body>
</html>
