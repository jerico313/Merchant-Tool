<?php
// Include the configuration file
require_once '../../inc/config.php';

// Create a database connection
$conn = new mysqli($db_host, $db_user, $db_password, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the promo codes from the request
$data = json_decode(file_get_contents('php://input'), true);
$promo_codes = $data['promo_code'];

// Prepare placeholders for the SQL query
$placeholders = implode(',', array_fill(0, count($promo_codes), '?'));
$stmt = $conn->prepare("SELECT promo_code FROM promo WHERE promo_code IN ($placeholders)");

// Bind parameters
$types = str_repeat('s', count($promo_codes));
$stmt->bind_param($types, ...$promo_codes);
$stmt->execute();
$result = $stmt->get_result();

$existing_codes = [];
while ($row = $result->fetch_assoc()) {
    $existing_codes[] = $row['promo_code']; // Fetch promo_code
}

$response = [
    'exists' => !empty($existing_codes),
    'ids' => $existing_codes
];

echo json_encode($response);

// Close statement and connection
$stmt->close();
$conn->close();
?>
