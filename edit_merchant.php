<?php
include("inc/config.php");

if (isset($_POST['merchant_id'])) {
    $merchant_id = $_POST['merchant_id'];
    $sql = "SELECT * FROM merchant WHERE merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $merchant = $result->fetch_assoc();
    echo json_encode($merchant);
}

$conn->close();
?>
