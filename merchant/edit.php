<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $merchantParntershipType = $_POST['merchantParntershipType'];
    $legalEntityName = $_POST['legalEntityName'];
    $businessAddress = $_POST['businessAddress'];
    $emailAddress = $_POST['emailAddress'];
    $sales = $_POST['sales'];
    $accountManager = $_POST['accountManager'];
    $userId = $_POST['userId'];

    // Check if value is empty and set it to NULL
    if ($merchantParntershipType == "Unknown partnership type") {
        $merchantParntershipType = NULL;
    }

    if (empty($legalEntityName)) {
        $legalEntityName = NULL;
    }

    if (empty($businessAddress)) {
        $businessAddress = NULL;
    }

    if (empty($emailAddress)) {
        $emailAddress = NULL;
    }

    if (empty($sales)) {
        $sales = NULL;
    }

    if (empty($accountManager)) {
        $accountManager = NULL;
    }   

    // Update merchant details
    $stmt = $conn->prepare("UPDATE merchant SET merchant_name=?, merchant_partnership_type=?, legal_entity_name=?, business_address=?, email_address=?, sales=?, account_manager=? WHERE merchant_id=?");
    $stmt->bind_param("ssssssss", $merchantName, $merchantParntershipType, $legalEntityName, $businessAddress, $emailAddress, $sales, $accountManager, $merchantId);

    if ($stmt->execute()) {
        // Find the latest inserted activity in activity_history
        $stmt->close();
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt->execute()) {
            $stmt->bind_result($latestActivityId);
            $stmt->fetch();
            $stmt->close();

            // Update the user_id column in the latest activity_history record
            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=? AND activity_type = 'Update'");
                $stmt->bind_param("ss", $userId, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }
        }

        // Redirect to the same page after a successful update
        header("Location: index.php");
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
        $stmt->close();
    }

    $conn->close();
}
?>
