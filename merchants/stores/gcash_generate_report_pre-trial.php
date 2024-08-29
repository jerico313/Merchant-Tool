<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../../inc/config.php");

    $storeId = $_POST['storeId'] ?? '';
    $storeName = $_POST['storeName'] ?? '';
    $merchantId = $_POST['merchantId'] ?? '';
    $merchantName = $_POST['merchantName'] ?? '';
    $startDate = $_POST['startDate'] ?? '';
    $endDate = $_POST['endDate'] ?? '';
    $userId = $_POST['userId'] ?? '';
    $billStatus = $_POST['billStatus'] ?? '';

    $sql = "CALL gcash_store_pretrial(?, ?, ?)";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("sss", $storeId, $startDate, $endDate);

    if ($stmt->execute()) {
        $result = $stmt->get_result();
        if ($result->num_rows === 0) {
            header("Location: failed.php?merchant_id=$merchantId&merchant_name=$merchantName");
            exit;
        }
        $stmt->close(); 

        $maxGcashReportId = null;
        $stmt = $conn->prepare("SELECT gcash_report_id FROM report_history_gcash_head ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($maxGcashReportId);
            $stmt->fetch();
            $stmt->close();
        }

        $storeIdHead = null;
        $stmt = $conn->prepare("SELECT store_id FROM report_history_gcash_head ORDER BY created_at DESC LIMIT 1");
        if ($stmt) {
            $stmt->execute();
            $stmt->bind_result($storeIdHead);
            $stmt->fetch();
            $stmt->close();
        }

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

        $storeIds = [$storeIdHead];
        $gcashReportIds = $gcashReportIdsBody;

        if ($maxGcashReportId !== null) {
            $stmt1 = $conn->prepare("UPDATE report_history_gcash_head SET generated_by=? WHERE gcash_report_id=?");
            if ($stmt1) {
                $stmt1->bind_param("ss", $userId, $maxGcashReportId);
                $stmt1->execute();
                $stmt1->close();
            }

            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE table_id=?");
            if ($stmt) {
                $stmt->bind_param("ss", $userId, $maxGcashReportId);
                if (!$stmt->execute()) {
                    echo "Error executing update statement for merchant_id: " . $stmt->error;
                }
                $stmt->close();
            } else {
                echo "Error preparing update statement for merchant_id: " . $conn->error;
            }
        }
        
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

        $store_id = htmlspecialchars($storeId);
        $store_name = htmlspecialchars($storeName);
        $settlement_period_start = htmlspecialchars($startDate);
        $settlement_period_end = htmlspecialchars($endDate);
        $bill_status = htmlspecialchars($billStatus);
        $url = 'reports/gcash_settlement_report.php?store_id=' . urlencode($store_id) . '&gcash_report_id=' . urlencode($maxGcashReportId) . '&store_name=' . urlencode($store_name) . '&settlement_period_start=' . urlencode($settlement_period_start) . '&settlement_period_end=' . urlencode($settlement_period_end) . '&bill_status=' . urlencode($bill_status);
        header("Location: $url");
        exit;
    } else {
        echo "Error executing stored procedure: " . $stmt->error;
    }

    $conn->close(); 
}
?>
