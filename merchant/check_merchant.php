<?php
// Include the configuration file
require_once '../inc/config.php';

// Create a database connection
$conn = new mysqli($db_host, $db_user, $db_password, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the merchant IDs from the request
$data = json_decode(file_get_contents('php://input'), true);
$merchant_ids = $data['merchant_ids'];

$placeholders = implode(',', array_fill(0, count($merchant_ids), '?'));
$stmt = $conn->prepare("SELECT merchant_id FROM merchant WHERE merchant_id IN ($placeholders)");

$types = str_repeat('s', count($merchant_ids));
$stmt->bind_param($types, ...$merchant_ids);
$stmt->execute();
$result = $stmt->get_result();

$existing_ids = [];
while ($row = $result->fetch_assoc()) {
    $existing_ids[] = $row['merchant_id'];
}

$response = [
    'exists' => !empty($existing_ids),
    'ids' => $existing_ids
];

echo json_encode($response);

// Close statement and connection
$stmt->close();
$conn->close();
?>
