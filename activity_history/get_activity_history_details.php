<?php
require_once('../inc/config.php');

if (isset($_POST['activityId'])) {
    $activityId = $_POST['activityId'];

    if ($stmt = $conn->prepare("SELECT table_id, table_name, column_name, description, created_at FROM activity_history_view WHERE activity_history_id = ?")) {
        $stmt->bind_param("s", $activityId);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            echo "<p><strong>Table Name:</strong> " . htmlspecialchars($row['table_name']) . "</p>";
            echo "<p><strong>Table ID:</strong> " . htmlspecialchars($row['table_id']) . "</p>";
            echo "<p><strong>Key Identifier:</strong> " . htmlspecialchars($row['column_name']) . "</p>";
            echo "<p><strong>Description:<br></strong> " . nl2br(htmlspecialchars($row['description'])) . "</p>";
            echo "<p><strong>Updated At:</strong> " . htmlspecialchars($row['created_at']) . "</p>";
        } else {
            echo "No details found for Activity ID: " . htmlspecialchars($activityId);
        }

        $stmt->close();
    } else {
        echo "Error: Unable to prepare the SQL statement.";
    }

    $conn->close();
} else {
    echo "Error: Activity ID not provided.";
}
?>
