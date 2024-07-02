<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $startDate = $_POST['startDate'];
    $endDate = $_POST['endDate'];
    $userId = $_POST['userId'];

    $sql = "CALL generate_merchant_coupled_report(?, ?, ?)";
    $stmt = $conn->prepare($sql);

    // Bind parameters to the prepared statement
    $stmt->bind_param("sss", $merchantId, $startDate, $endDate);

    if ($stmt->execute()) {
        $stmt->close(); // Close the first statement
        
        // Get the latest activity_id from activity_history
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestActivityId);
        $stmt->fetch(); // Fetch the result
        $stmt->close(); // Close the statement

        // Get the max coupled_report_id from report_history_coupled
        $stmt = $conn->prepare("SELECT coupled_report_id FROM report_history_coupled ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($maxCoupledReportId);
        $stmt->fetch(); // Fetch the result
        $stmt->close(); // Close the statement

        if ($latestActivityId) {
            // Update activity_history with user_id
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
            $stmt->bind_param("ss", $userId, $latestActivityId);
            $stmt->execute();
            $stmt->close(); // Close the statement
        }

        if ($maxCoupledReportId) {
            // Redirect to the report page with parameters
            $merchant_id = htmlspecialchars($merchantId);
            $merchant_name = htmlspecialchars($merchantName);
            $url = "reports/coupled_settlement_report.php?merchant_id=$merchant_id&merchant_name=$merchant_name&coupled_report_id=$maxCoupledReportId";
            
            header("Location: $url");
            exit;
        } else {
            echo json_encode(['error' => 'No data found in report_history_coupled']);
        }
    } else {
        echo "Error executing stored procedure: " . $stmt->error;
    }

    $conn->close(); // Close the database connection
}
?>
