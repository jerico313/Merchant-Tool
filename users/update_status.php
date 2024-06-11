<?php
include("../inc/config.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $userId = $_POST['userId'];
    $status = $_POST['status'];

    // Ensure the status is either 'active' or 'inactive'
    if (!in_array($status, ['active', 'inactive'])) {
        echo json_encode(['error' => 'Invalid status value']);
        exit;
    }

    // Prepare and bind
    $stmt = $conn->prepare("UPDATE user SET status = ? WHERE user_id = ?");
    $stmt->bind_param("ss", $status, $userId);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['error' => 'Failed to update status']);
    }

    $stmt->close();
}

$conn->close();
?>
