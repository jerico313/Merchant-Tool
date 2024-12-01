<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $feeId = $_POST['feeId'];
    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $paymayaCreditCard = $_POST['paymayaCreditCard'];
    $gcash = $_POST['gcash'];
    $gcashMiniapp = $_POST['gcashMiniapp'];
    $paymaya = $_POST['paymaya'];
    $leadgenCommission = $_POST['leadgenCommission'];
    $commissionType = $_POST['commissionType'];
    $effectiveDate = $_POST['effectiveDate'];
    $userId = $_POST['userId'];

    $stmt = $conn->prepare("UPDATE fee SET paymaya_credit_card=?, gcash=?, gcash_miniapp=?, paymaya=?, maya_checkout=?, maya=?, lead_gen_commission=?, commission_type=?, effective_date=? WHERE fee_id=?");
    $stmt->bind_param("ssssssssss", $paymayaCreditCard, $gcash, $gcashMiniapp, $paymaya, $paymayaCreditCard, $paymayaCreditCard, $leadgenCommission, $commissionType, $effectiveDate, $feeId);

    if ($stmt->execute()) {
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestActivityId);
        $stmt->fetch();
        $stmt->close();

        if ($latestActivityId) {
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
            $stmt->bind_param("ss", $userId, $latestActivityId);
            $stmt->execute();
            $stmt->close();
        }

        header("Location: history.php?merchant_name=" . $merchantName . "&merchant_id=" . htmlspecialchars($merchantId));
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
    }

    $conn->close();
}
?>
