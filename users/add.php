<?php
include("../inc/config.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Retrieve POST data
    $name = $_POST['name'];
    $emailAddress = $_POST['emailAddress'];
    $type = $_POST['type'];
    $user_id = $_POST['userId'];

    // Check if the email already exists
    $stmt = $conn->prepare("SELECT COUNT(*) FROM user WHERE email_address = ?");
    $stmt->bind_param("s", $emailAddress);
    $stmt->execute();
    $stmt->bind_result($emailCount);
    $stmt->fetch();
    $stmt->close();

    if ($emailCount > 0) {
        // Email already exists
        echo "Error: The email address is already registered.";
    } else {
        // Prepare and execute the insert statement
        $stmt = $conn->prepare("INSERT INTO user (name, email_address, type) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $name, $emailAddress, $type);
        $stmt->execute();
        $stmt->close();

        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt->execute()) {
            $stmt->bind_result($latestActivityId);
            $stmt->fetch();
            $stmt->close();

            // Update the user_id column in the latest activity_history record
            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
                $stmt->bind_param("ss", $user_id, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }
        }

        // Redirect to the same page after a successful update
        header("Location: index.php");
        exit();
    }
}

$conn->close();
?>