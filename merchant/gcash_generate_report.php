<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $startDate = $_POST['startDate'];
    $endDate = $_POST['endDate'];
    $userId = $_POST['userId'];

    $sql = "CALL generate_merchant_gcash_report(?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $merchantId, $startDate, $endDate);

    if ($stmt->execute()) {
        $stmt->close();

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

        $stmt = $conn->prepare("SELECT gcash_report_id FROM report_history_gcash_head ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($maxGCashReportId);
        $stmt->fetch();
        $stmt->close();

        if ($maxGCashReportId) {

            $merchant_id = htmlspecialchars($merchantId);
            $merchant_name = htmlspecialchars($merchantName);
            $url = "reports/gcash_settlement_report.php?merchant_id=$merchant_id&merchant_name=$merchant_name&gcash_report_id=$maxGCashReportId";
            
            header("Location: $url");
            exit;
        } else {
            header("Location: failed.php");
            exit;
        }
    } else {
        echo "Error executing stored procedure: " . $stmt->error;
    }

    $conn->close();
}
?>
