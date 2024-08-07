<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../../inc/config.php");

    $storeId = $_POST['storeId'] ?? '';
    $storeId = $_POST['storeId'] ?? '';
    $merchantId = $_POST['merchantId'] ?? '';
    $merchantName = $_POST['merchantName'] ?? '';
    $startDate = $_POST['startDate'] ?? '';
    $endDate = $_POST['endDate'] ?? '';
    $userId = $_POST['userId'] ?? '';
    $billStatus = $_POST['billStatus'] ?? '';

    $sql = "CALL coupled_store_pretrial(?, ?, ?)";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    // Bind parameters to the prepared statement
    $stmt->bind_param("sss", $storeId, $startDate, $endDate);

    if ($stmt->execute()) {
        $result = $stmt->get_result();
        if ($result->num_rows === 0) {
            // No rows returned, redirect to failed.php
            header("Location: failed.php?merchant_id=$merchantId&merchant_name=$merchantName");
            exit;
        }
        $stmt->close(); // Close the first statement

        // Get the latest activity_id from activity_history
        $latestActivityId = null;
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($latestActivityId);
            $stmt->fetch(); // Fetch the result
            $stmt->close(); // Close the statement
        }

        // Get the max coupled_report_id from report_history_coupled
        $maxCoupledReportId = null;
        $stmt = $conn->prepare("SELECT coupled_report_id FROM report_history_coupled ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($maxCoupledReportId);
            $stmt->fetch(); // Fetch the result
            $stmt->close(); // Close the statement
        }

        if ($latestActivityId !== null && $maxCoupledReportId !== null) {
            // Update activity_history with user_id
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
            if ($stmt) {
                $stmt->bind_param("ss", $userId, $latestActivityId);
                $stmt->execute();
                $stmt->close(); // Close the statement
            }

            // Redirect to the report page with parameters
            $store_id = htmlspecialchars($storeId);
            $store_name = htmlspecialchars($storeId);
            $settlement_period_start = htmlspecialchars($startDate);
            $settlement_period_end = htmlspecialchars($endDate);
            $bill_status = htmlspecialchars($billStatus);
            $url = 'reports/coupled_settlement_report.php?store_id=' . urlencode($store_id) . '&coupled_report_id=' . urlencode($maxCoupledReportId) . '&store_name=' . urlencode($store_name) . '&settlement_period_start=' . urlencode($settlement_period_start) . '&settlement_period_end=' . urlencode($settlement_period_end) . '&bill_status=' . urlencode($bill_status);
            header("Location: $url");
            exit;
        } else {
            header("Location: ../failed.php");
            exit;
        }
    } else {
        echo "Error executing stored procedure: " . $stmt->error;
    }

    $conn->close(); // Close the database connection
}
?>
