<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'] ?? '';
    $merchantName = $_POST['merchantName'] ?? '';
    $startDate = $_POST['startDate'] ?? '';
    $endDate = $_POST['endDate'] ?? '';
    $userId = $_POST['userId'] ?? '';

    $sql = "CALL generate_merchant_gcash_report(?, ?, ?)";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("sss", $merchantId, $startDate, $endDate);

    if ($stmt->execute()) {
        $result = $stmt->get_result();
        if ($result->num_rows === 0) {
            header("Location: failed.php");
            exit;
        }
        $stmt->close(); // Close the first statement

        $latestActivityId = null;
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($latestActivityId);
            $stmt->fetch(); 
            $stmt->close(); 
        }

        $maxGcashReportId = null;
        $stmt = $conn->prepare("SELECT gcash_report_id FROM report_history_gcash_head ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($maxGcashReportId);
            $stmt->fetch(); // Fetch the result
            $stmt->close(); // Close the statement
        }

        if ($latestActivityId !== null && $maxGcashReportId !== null) {
            // Update activity_history with user_id
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
            if ($stmt) {
                $stmt->bind_param("ss", $userId, $latestActivityId);
                $stmt->execute();
                $stmt->close(); // Close the statement
            }

            $merchant_id = htmlspecialchars($merchantId);
            $merchant_name = htmlspecialchars($merchantName);
            $settlement_period_start = htmlspecialchars($startDate);
            $settlement_period_end = htmlspecialchars($endDate);
            $url = "reports/gcash_settlement_report.php?merchant_id=$merchant_id&gcash_report_id=$maxGcashReportId&merchant_name=$merchant_name&settlement_period_start=$settlement_period_start&settlement_period_end=$settlement_period_end";
            
            header("Location: $url");
            exit;
        } else {
            header("Location: failed.php");
            exit;
        }
    } else {
        echo "Error executing stored procedure: " . $stmt->error;
    }

    $conn->close(); // Close the database connection
}
?>
