<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $user_Id = $_POST['user_Id'];
    $name = $_POST['name'];
    $emailAddress = $_POST['emailAddress'];
    $type = $_POST['type'];
    $department = $_POST['department'];
    $status = $_POST['status'];
    $newPassword = $_POST['newPassword'];
    $userId = $_POST['userId'];

    // Check if a new password is provided
    if (!empty($newPassword)) {
        // Hash the new password
        $hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);
    } else {
        $hashedPassword = null; // Set to null if no new password is provided
    }

    // Prepare the update query
    if ($hashedPassword !== null) {
        $stmt = $conn->prepare("UPDATE user SET name=?, email_address=?, type=?, department=?, status=?, password=? WHERE user_id=?");
        $stmt->bind_param("sssssss", $name, $emailAddress, $type, $department, $status, $hashedPassword, $user_Id);
    } else {
        $stmt = $conn->prepare("UPDATE user SET name=?, email_address=?, type=?, department=?, status=? WHERE user_id=?");
        $stmt->bind_param("ssssss", $name, $emailAddress, $type, $department, $status, $user_Id);
    }

    if ($stmt->execute()) {
        // Find the latest inserted activity in activity_history
        $stmt->close();
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt->execute()) {
            $stmt->bind_result($latestActivityId);
            $stmt->fetch();
            $stmt->close();

            // Update the user_id column in the latest activity_history record
            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
                $stmt->bind_param("si", $userId, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }
        }

        // Redirect to the same page after a successful update
        header("Location: index.php");
        exit();
    } else {
        // Debugging output to ensure we see what went wrong
        echo "Error updating record: " . $stmt->error;
        $stmt->close();
    }

    $conn->close();
} else {
    // Handle case where the request method is not POST
    echo "Invalid request method.";
}
?>
