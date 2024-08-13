<?php
require_once '../../inc/config.php';

$conn = new mysqli($db_host, $db_user, $db_password, $db_name);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$data = json_decode(file_get_contents('php://input'), true);
$store_ids = $data['store_ids'];

$placeholders = implode(',', array_fill(0, count($store_ids), '?'));
$stmt = $conn->prepare("SELECT store_id FROM store WHERE store_id IN ($placeholders)");

$types = str_repeat('s', count($store_ids));
$stmt->bind_param($types, ...$store_ids);
$stmt->execute();
$result = $stmt->get_result();

$existing_ids = [];
while ($row = $result->fetch_assoc()) {
    $existing_ids[] = $row['store_id'];
}

$response = [
    'exists' => !empty($existing_ids),
    'ids' => $existing_ids
];

echo json_encode($response);

$stmt->close();
$conn->close();
?>
