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
    $userId = $_POST['userId'];

    // Update promo details
    $stmt = $conn->prepare("UPDATE promo SET promo_code=?, promo_details=?, promo_amount=?, voucher_type=?, bill_status=?, promo_category=?, promo_group=?, promo_type=?, start_date=?, end_date=? WHERE promo_id=?");
    $stmt->bind_param("sssssssssss", $promoCode, $promoDetails, $promoAmount, $voucherType, $billStatus, $promoCategory, $promoGroup, $promoType, $startDate, $endDate, $promoId);

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
        header("Location: index.php?merchant_id=" . htmlspecialchars($merchantId) . "&merchant_name=" . htmlspecialchars($merchantName));
        exit();
    } else {
        error_log("Error updating record: " . $stmt->error);
        echo "An error occurred while updating the record. Please try again later.";
    }

    $conn->close();
}
?>
