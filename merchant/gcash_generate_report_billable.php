<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'] ?? '';
    $merchantName = $_POST['merchantName'] ?? '';
    $startDate = $_POST['startDate'] ?? '';
    $endDate = $_POST['endDate'] ?? '';
    $userId = $_POST['userId'] ?? '';
    $billStatus = $_POST['billStatus'] ?? '';

    $sql = "CALL gcash_merchant_billable(?, ?, ?)";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("sss", $merchantId, $startDate, $endDate);

    if ($stmt->execute()) {
        $stmt->close(); // Close the first statement

        $maxGcashReportId = null;
        $stmt = $conn->prepare("SELECT gcash_report_id FROM report_history_gcash_head ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($maxGcashReportId);
            $stmt->fetch(); // Fetch the result
            $stmt->close(); // Close the statement
        }

        $merchantIdHead = null;
        $stmt = $conn->prepare("SELECT merchant_id FROM report_history_gcash_head ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($merchantIdHead);
            $stmt->fetch();
            $stmt->close();
        }

        // Fetch all gcash_report_id's from report_history_gcash_body
        $gcashReportIdsBody = [];
        $stmt = $conn->prepare("SELECT DISTINCT gcash_report_id FROM report_history_gcash_body WHERE created_at >= (SELECT created_at FROM report_history_gcash_head ORDER BY created_at DESC LIMIT 1)");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($gcashReportId);
            while ($stmt->fetch()) {
                $gcashReportIdsBody[] = $gcashReportId;
            }
            $stmt->close();
        }

        // Combine both merchant_id from head and gcash_report_id from body
        $merchantIds = [$merchantIdHead];
        $gcashReportIds = $gcashReportIdsBody;

        // Update user_id in activity_history based on merchant_id
        if ($merchantIdHead) {
            $pattern = '%merchant_id: ' . $merchantIdHead . '%';
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE description LIKE ? AND user_id IS NULL");
            if ($stmt) {
                $stmt->bind_param("ss", $userId, $pattern);
                if (!$stmt->execute()) {
                    echo "Error executing update statement for merchant_id: " . $stmt->error;
                }
                $stmt->close();
            } else {
                echo "Error preparing update statement for merchant_id: " . $conn->error;
            }
        }

        // Update user_id in activity_history based on gcash_report_id
        foreach ($gcashReportIds as $reportId) {
            $pattern = '%gcash_report_id: ' . $reportId . '%';
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE description LIKE ? AND user_id IS NULL");
            if ($stmt) {
                $stmt->bind_param("ss", $userId, $pattern);
                if (!$stmt->execute()) {
                    echo "Error executing update statement for gcash_report_id: " . $stmt->error;
                }
                $stmt->close();
            } else {
                echo "Error preparing update statement for gcash_report_id: " . $conn->error;
            }
        }

        // Redirect to the first generated report URL (you can customize this as needed)
        $merchant_id = htmlspecialchars($merchantId);
        $merchant_name = htmlspecialchars($merchantName);
        $settlement_period_start = htmlspecialchars($startDate);
        $settlement_period_end = htmlspecialchars($endDate);
        $bill_status = htmlspecialchars($billStatus);
        $url = 'reports/gcash_settlement_report.php?merchant_id=' . urlencode($merchant_id) . '&gcash_report_id=' . urlencode($maxGcashReportId) . '&merchant_name=' . urlencode($merchant_name) . '&settlement_period_start=' . urlencode($settlement_period_start) . '&settlement_period_end=' . urlencode($settlement_period_end). '&merchant_name=' . urlencode($merchant_name) . '&bill_status=' . urlencode($bill_status); 
        header("Location: $url");
        exit;
    } else {
        echo "Error executing stored procedure: " . $stmt->error;
    }

    $conn->close(); // Close the database connection
}
?>
