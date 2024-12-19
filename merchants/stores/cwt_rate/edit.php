<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../../inc/config.php");

    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $storeId = $_POST['storeId'];
    $storeName = $_POST['storeName']; 
    $cwt_rate_id = $_POST['feeId'];
    $cwt_rate = $_POST['merchantId'];
    $effective_date = $_POST['effectiveDate'];
    $userId = $_POST['userId'];

    $stmt = $conn->prepare("UPDATE cwt_rate SET cwt_rate=?, effective_date=? WHERE cwt_rate_id=?");
    $stmt->bind_param("sss", $cwt_rate, $effective_date, $cwt_rate_id);

    if ($stmt->execute()) {
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history WHERE cwt_rate_id=? ORDER BY created_at DESC LIMIT 1");
        $stmt->bind_param("s", $cwt_rate_id);
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

        header("Location: index.php?merchant_name=" . $merchantName . "&merchant_id=" . htmlspecialchars($merchantId) . "&store_id=" . htmlspecialchars($storeId) . "&store_name=" . htmlspecialchars($storeName));
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
    }

    $conn->close();
}
?>
