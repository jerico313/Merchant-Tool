<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $feeId = $_POST['feeId'];
    
    $paymayaCreditCard = $_POST['paymayaCreditCard'];
    $gcash = $_POST['gcash'];
    $gcashMiniapp = $_POST['gcashMiniapp'];
    $paymaya = $_POST['paymaya'];
    $gcash = $_POST['gcash'];
    $gcashMiniapp = $_POST['gcashMiniapp'];
    $paymaya = $_POST['paymaya'];
    $leadgenCommission = $_POST['leadgenCommission'];
    $commissionType = $_POST['commissionType'];
    $userId = $_POST['userId'];

    $stmt = $conn->prepare("UPDATE fee SET paymaya_credit_card=?, gcash=?, gcash_miniapp=?, paymaya=?, maya_checkout=?, maya=?, lead_gen_commission=?, commission_type=? WHERE fee_id=?");
    $stmt->bind_param("sssssssss", $paymayaCreditCard, $gcash, $gcashMiniapp, $paymaya,  $paymayaCreditCard,  $paymayaCreditCard, $leadgenCommission, $commissionType, $feeId);

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
        
        $stmt = $conn->prepare("SELECT fee_history_id FROM fee_history ORDER BY changed_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestFeeHistoryId);
        $stmt->fetch();
        $stmt->close();
        
        if ($latestFeeHistoryId) {
            $stmt = $conn->prepare("UPDATE fee_history SET changed_by=? WHERE fee_history_id=?");
            $stmt->bind_param("ss", $userId, $latestFeeHistoryId);
            $stmt->execute();
            $stmt->close();
        }

        header("Location: index.php");
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
    }

    $conn->close();
}
?>
