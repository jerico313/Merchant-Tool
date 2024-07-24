<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $feeId = $_POST['feeId'];
    
    $paymayaCreditCard = substr($_POST['paymayaCreditCard'], 0, -1);
    $gcash = substr($_POST['gcash'], 0, -1);
    $gcashMiniapp = substr($_POST['gcashMiniapp'], 0, -1);
    $paymaya = substr($_POST['paymaya'], 0, -1);
    $gcash = substr($_POST['gcash'], 0, -1);
    $gcashMiniapp = substr($_POST['gcashMiniapp'], 0, -1);
    $paymaya = substr($_POST['paymaya'], 0, -1);
    $leadgenCommission = substr($_POST['leadgenCommission'], 0, -1);
    $commissionType = $_POST['commissionType'];
    $cwtRate = substr($_POST['cwtRate'], 0, -1);
    $userId = $_POST['userId'];

    // Update fee details
    $stmt = $conn->prepare("UPDATE fee SET paymaya_credit_card=?, gcash=?, gcash_miniapp=?, paymaya=?, maya_checkout=?, maya=?, lead_gen_commission=?, commission_type=?, cwt_rate=? WHERE fee_id=?");
    $stmt->bind_param("ssssssssss", $paymayaCreditCard, $gcash, $gcashMiniapp, $paymaya,  $paymayaCreditCard,  $paymayaCreditCard, $leadgenCommission, $commissionType, $cwtRate, $feeId);

    if ($stmt->execute()) {
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

        // Redirect to the same page after successful update
        header("Location: index.php");
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
    }

    $conn->close();
}
?>
