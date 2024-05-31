<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("inc/config.php");

    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $merchantPartnershipType = $_POST['merchantPartnershipType'];
    $merchantType = $_POST['merchantType'];
    $businessAddress = $_POST['businessAddress'];
    $emailAddress = $_POST['emailAddress'];

    $stmt = $conn->prepare("UPDATE merchant SET merchant_name=?, merchant_partnership_type=?, merchant_type=?,business_address=?, email_address=? WHERE merchant_id=?");
    $stmt->bind_param("ssssss", $merchantName, $merchantPartnershipType, $merchantType, $businessAddress, $emailAddress, $merchantId);

    if ($stmt->execute()) {
        // Redirect to the same page after successful update
        header("Location: merchant.php");
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
}
?>