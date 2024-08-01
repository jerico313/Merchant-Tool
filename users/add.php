<?php 
include("../inc/config.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Retrieve POST data
    $name = $_POST['name'];
    $emailAddress = $_POST['emailAddress'];
    $type = $_POST['type'];
    $department = $_POST['department'];
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
        $stmt = $conn->prepare("INSERT INTO user (name, email_address, type, department) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $name, $emailAddress, $type, $department);

        if ($stmt->execute()) {
            // Get the user_id of the newly inserted user
            $newUserId = $stmt->insert_id;
            $stmt->close();

            // Find the latest inserted activity in activity_history
            $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
            $stmt->execute();
            $stmt->bind_result($latestActivityId);
            $stmt->fetch();
            $stmt->close();

            // Update the user_id column in the latest activity_history record
            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
                $stmt->bind_param("ii", $newUserId, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }

            // Redirect to the same page after a successful update
            header("Location: index.php");
            exit();
        } else {
            echo "Error inserting record: " . $stmt->error;
            $stmt->close();
        }
    }

    $conn->close();
}
?>