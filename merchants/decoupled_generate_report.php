<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'] ?? '';
    $merchantName = $_POST['merchantName'] ?? '';
    $startDate = $_POST['startDate'] ?? '';
    $endDate = $_POST['endDate'] ?? '';
    $userId = $_POST['userId'] ?? '';
    $billStatus = $_POST['billStatus'] ?? '';

    $sql = "CALL decoupled_merchant_all(?, ?, ?)";
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
        $stmt->close(); 

        $maxDecoupledReportId = null;
        $stmt = $conn->prepare("SELECT decoupled_report_id FROM report_history_decoupled ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($maxDecoupledReportId);
            $stmt->fetch(); 
            $stmt->close(); 
        }

        if ($maxDecoupledReportId !== null) {
            $stmt1 = $conn->prepare("UPDATE report_history_decoupled SET generated_by=? WHERE decoupled_report_id=?");
            if ($stmt1) {
                $stmt1->bind_param("ss", $userId, $maxDecoupledReportId);
                $stmt1->execute();
                $stmt1->close();
            }

            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE table_id=?");
            if ($stmt) {
                $stmt->bind_param("ss", $userId, $maxDecoupledReportId);
                $stmt->execute();
                $stmt->close(); 
            }

            $merchant_id = htmlspecialchars($merchantId);
            $merchant_name = htmlspecialchars($merchantName);
            $settlement_period_start = htmlspecialchars($startDate);
            $settlement_period_end = htmlspecialchars($endDate);
            $bill_status = htmlspecialchars($billStatus);
            $url = 'reports/decoupled_settlement_report.php?merchant_id=' . urlencode($merchant_id) . '&decoupled_report_id=' . urlencode($maxDecoupledReportId) . '&merchant_name=' . urlencode($merchant_name) . '&settlement_period_start=' . urlencode($settlement_period_start) . '&settlement_period_end=' . urlencode($settlement_period_end) . '&bill_status=' . urlencode($bill_status);            
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
