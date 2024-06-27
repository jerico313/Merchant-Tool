<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'];
    $paymayaCreditCard = $_POST['paymayaCreditCard'];
    $gcash = $_POST['gcash'];
    $gcashMiniapp = $_POST['gcashMiniapp'];
    $paymaya = $_POST['paymaya'];
    $mayaCheckout = $_POST['mayaCheckout'];
    $maya = $_POST['maya'];

    $stmt = $conn->prepare("UPDATE merchant SET merchant_name=?, merchant_partnership_type=?, legal_entity_name=?, business_address=?, email_address=? WHERE merchant_id=?");
    $stmt->bind_param("ssssss", $merchantName, $merchantPartnershipType, $legalEntityName, $businessAddress, $emailAddress, $merchantId);

    if ($stmt->execute()) {
        // Redirect to the same page after successful update
        header("Location: index.php");
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
}
?>