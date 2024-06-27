<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $feeId = $_POST['feeId'];
    $paymayaCreditCard = $_POST['paymayaCreditCard'];
    $gcash = $_POST['gcash'];
    $gcashMiniapp = $_POST['gcashMiniapp'];
    $paymaya = $_POST['paymaya'];
    $mayaCheckout = $_POST['mayaCheckout'];
    $maya = $_POST['maya'];
    $leadgenCommission = $_POST['leadgenCommission'];
    $commissionType = $_POST['commissionType'];
    $userId = $_POST['userId'];

    $stmt = $conn->prepare("UPDATE fee SET paymaya_credit_card=?, gcash=?, gcash_miniapp=?, paymaya=?, maya_checkout=?, maya=?, lead_gen_commission=?, commission_type=? WHERE fee_id=?");
    $stmt->bind_param("sssssssss", $paymayaCreditCard, $gcash, $gcashMiniapp, $paymaya, $mayaCheckout, $maya, $leadgenCommission, $commissionType, $feeId);

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
