<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../../inc/config.php");

    // Retrieve the form data
    $promoId = $_POST['promoId'];
    $promoCode = $_POST['promoCode'];
    $promoDetails = $_POST['promoDetails'];
    $promoAmount = $_POST['promoAmount'];
    $voucherType = $_POST['voucherType'];
    $billStatus = $_POST['billStatus'];
    $promoCategory = $_POST['promoCategory'];
    $promoGroup = $_POST['promoGroup'];
    $promoType = $_POST['promoType'];
    $startDate = $_POST['startDate'];
    $endDate = $_POST['endDate'];
    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];

    // Prepare the SQL statement
    $stmt = $conn->prepare("UPDATE promo SET promo_code=?, promo_details=?, promo_amount=?, voucher_type=?, bill_status=?,promo_category=?, promo_group=?, promo_type=?, start_date=?, end_date=? WHERE promo_id=?");
    $stmt->bind_param("sssssssssss", $promoCode, $promoDetails, $promoAmount, $voucherType, $billStatus, $promoCategory, $promoGroup, $promoType, $startDate, $endDate, $promoId);

    // Execute the statement and check for errors 
    if ($stmt->execute()) {
        // Redirect to the store page with the merchant_id and merchant_name after a successful update
        header("Location: index.php?merchant_id=" . htmlspecialchars($merchantId) . "&merchant_name=" . htmlspecialchars($merchantName));
        exit();
    } else {
        // Log error message
        error_log("Error updating record: " . $stmt->error);
        echo "An error occurred while updating the record. Please try again later.";
    }

    // Close the statement and connection
    $stmt->close();
    $conn->close();
}
?>
