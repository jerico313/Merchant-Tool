<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $user_Id = $_POST['user_Id'];
    $name = $_POST['name'];
    $emailAddress = $_POST['emailAddress'];
    $type = $_POST['type'];
    $status = $_POST['status'];
    $userId = $_POST['userId'];

    $stmt = $conn->prepare("UPDATE user SET name=?, email_address=?, type=?, status=? WHERE user_id=?");
    $stmt->bind_param("sssss", $name, $emailAddress, $type, $status, $user_Id);

    if ($stmt->execute()) {
        $stmt->close();
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt->execute()) {
            $stmt->bind_result($latestActivityId);
            $stmt->fetch();
            $stmt->close();

            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
                $stmt->bind_param("si", $userId, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }
        }

        header("Location: index.php");
        exit();
    } else {
        echo "Error updating record: " . $stmt->error;
        $stmt->close();
    }

    $conn->close();
} else {
    echo "Invalid request method.";
}
?>
