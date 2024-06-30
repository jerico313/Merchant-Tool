<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $merchantPartnershipType = $_POST['merchantPartnershipType'];
    $legalEntityName = $_POST['legalEntityName'];
    $businessAddress = $_POST['businessAddress'];
    $emailAddress = $_POST['emailAddress'];
    $userId = $_POST['userId'];

    // Update merchant details
    $stmt = $conn->prepare("UPDATE merchant SET merchant_name=?, merchant_partnership_type=?, legal_entity_name=?, business_address=?, email_address=? WHERE merchant_id=?");
    $stmt->bind_param("ssssss", $merchantName, $merchantPartnershipType, $legalEntityName, $businessAddress, $emailAddress, $merchantId);

    if ($stmt->execute()) {
        // Find the latest inserted activity in activity_history
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestActivityId);
        $stmt->fetch();
        $stmt->close();

        // Update the user_id column in the latest activity_history record
        if ($latestActivityId) {
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
            $stmt->bind_param("ss", $userId, $latestActivityId);
            $stmt->execute();
            $stmt->close();
        }

        // Redirect to the same page after successful update
        header("Location: index.php");
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
    }

    $conn->close();
}
?>
