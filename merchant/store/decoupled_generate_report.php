<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../../inc/config.php");

    $storeId = $_POST['storeId'];
    $storeName = $_POST['storeName'];
    $startDate = $_POST['startDate'];
    $endDate = $_POST['endDate'];
    $userId = $_POST['userId'];

    $sql = "CALL generate_store_decoupled_report(?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $storeId, $startDate, $endDate);

    if ($stmt->execute()) {
        $stmt->close();

        // Retrieve latest activity_id
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestActivityId);
        $stmt->fetch();
        $stmt->close();

        // Retrieve max decoupled_report_id
        $stmt = $conn->prepare("SELECT decoupled_report_id FROM report_history_decoupled ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($maxDecoupledReportId);
        $stmt->fetch();
        $stmt->close();

        if ($maxDecoupledReportId) {
            // Update activity_history with user_id
            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
                $stmt->bind_param("ss", $userId, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }

            // Redirect to decoupled_settlement_report.php
            $store_id = htmlspecialchars($storeId);
            $store_name = htmlspecialchars($storeName);
            $settlement_period_start = htmlspecialchars($startDate);
            $settlement_period_end = htmlspecialchars($endDate);
            $url = "reports/decoupled_settlement_report.php?store_id=$store_id&_name=$store_name&decoupled_report_id=$maxDecoupledReportId&settlement_period_start=$settlement_period_start&settlement_period_end=$settlement_period_end";
            
            header("Location: $url");
            exit;
        } else {
            // Redirect to failed.php if no report found
            header("Location: failed.php");
            exit;
        }
    } else {
        echo "Error executing stored procedure: " . $stmt->error;
    }

    $conn->close();
}
?>
