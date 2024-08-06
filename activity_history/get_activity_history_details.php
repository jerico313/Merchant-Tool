<?php
require_once('../inc/config.php');

if (isset($_POST['activityId'])) {
    $activityId = $_POST['activityId'];

    // Prepare the SQL statement
    if ($stmt = $conn->prepare("SELECT table_name, column_name, description FROM activity_history_view WHERE activity_history_id = ?")) {
        // Bind the activityId parameter to the prepared statement
        $stmt->bind_param("s", $activityId);
        // Execute the statement
        $stmt->execute();
        // Get the result
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            echo "<p><strong>Table Name:</strong> " . htmlspecialchars($row['table_name']) . "</p>";
            echo "<p><strong>Key Identifier:</strong> " . htmlspecialchars($row['column_name']) . "</p>";
            echo "<p><strong>Description:<br></strong> " . nl2br(htmlspecialchars($row['description'])) . "</p>";
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
