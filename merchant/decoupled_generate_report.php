<?php
include("../inc/config.php");

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Retrieve POST data
    $merchant_id = isset($_POST['merchant_id']) ? $_POST['merchant_id'] : '';
    $start_date = isset($_POST['start_date']) ? $_POST['start_date'] : '';
    $end_date = isset($_POST['end_date']) ? $_POST['end_date'] : '';

    // Prepare SQL statement for calling stored procedure
    $sql = "CALL generate_merchant_decoupled_report(?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $merchant_id, $start_date, $end_date);

    // Execute the statement
    $stmt->execute();
    
    header("Location: decoupled_settlement_report.php");
    $result = $stmt->get_result();

    // Check if there are rows returned
    if ($result->num_rows > 0) {
        // Initialize an array to store fetched data
        $data = [];

        // Fetch rows and add to $data array
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }

        // Close statement and database connection
        $stmt->close();
        $conn->close();

        header("Location: settlement_reports.php");
        exit;
    } else {
        // If no rows were returned, handle accordingly (optional)
        $stmt->close();
        $conn->close();
        echo json_encode(['error' => 'No data found']);
    }
} else {
    // If request method is not POST, handle accordingly (optional)
    echo json_encode(['error' => 'Invalid request method']);
}
?>
