<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../../inc/config.php");

    $promoId = $_POST['promoId'];
    $promoCode = $_POST['promoCode'];
    $promoAmount = $_POST['promoAmount'];
    $voucherType = $_POST['voucherType'];
    $promoCategory = $_POST['promoCategory'];
    $promoType = $_POST['promoType'];
    $promoGroup = $_POST['promoGroup'];
    $promoDetails = $_POST['promoDetails'];
    $remarks = empty($_POST['remarks']) ? NULL : $_POST['remarks'];
    $billStatus = $_POST['billStatus'];
    $startDate = $_POST['startDate'];
    $endDate = $_POST['endDate'];
    $remarks2 = empty($_POST['remarks2']) ? NULL : $_POST['remarks2'];
    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $userId = $_POST['userId'];

    $stmt = $conn->prepare("UPDATE promo SET promo_code=?, promo_amount=?, voucher_type=?, promo_category=?, promo_type=?, promo_group=?, promo_details=?, remarks=?, bill_status=?, start_date=?, end_date=?, remarks2=? WHERE promo_id=?");
    $stmt->bind_param("sssssssssssss", $promoCode, $promoAmount, $voucherType, $promoCategory, $promoType, $promoGroup, $promoDetails, $remarks, $billStatus, $startDate, $endDate, $remarks2, $promoId);

    if ($stmt->execute()) {  
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestActivityId);
        $stmt->fetch();
        $stmt->close();

        $stmt = $conn->prepare("SELECT promo_history_id FROM promo_history ORDER BY changed_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestPromoHistoryId);
        $stmt->fetch();
        $stmt->close();
        if ($latestActivityId) {
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
            $stmt->bind_param("ss", $userId, $latestActivityId);
            $stmt->execute();
            $stmt->close();
        }
        
        if ($latestPromoHistoryId) {
            $stmt = $conn->prepare("UPDATE promo_history SET changed_by=? WHERE promo_history_id=?");
            $stmt->bind_param("ss", $userId, $latestPromoHistoryId);
            $stmt->execute();
            $stmt->close();
        }


        header("Location: index.php?merchant_id=" . htmlspecialchars($merchantId) . "&merchant_name=" . htmlspecialchars($merchantName));
        exit();
    } else {
        error_log("Error updating record: " . $stmt->error);
        echo "An error occurred while updating the record. Please try again later.";
    }

    $conn->close();
}
?>
