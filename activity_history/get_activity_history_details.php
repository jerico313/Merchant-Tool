<?php
require_once('../inc/config.php');

if (isset($_POST['activityId'])) {
    $activityId = $_POST['activityId'];

    // Prepare the SQL statement
<<<<<<< HEAD
    $stmt = $conn->prepare("SELECT table_name, description FROM activity_history_view WHERE activity_history_id = ?");
=======
    $stmt = $conn->prepare("SELECT * FROM activity_history_view WHERE activity_history_id = ?");
>>>>>>> ccd3ee5418cf5cf63217c3e561c9032d89f315e3
    // Bind the activityId parameter to the prepared statement
    $stmt->bind_param("i", $activityId);
    // Execute the statement
    $stmt->execute();
    // Get the result
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo "<p><strong>Table ID:</strong> " . htmlspecialchars($row['table_id']) . "</p>";
        echo "<p><strong>Table Name:</strong> " . htmlspecialchars($row['table_name']) . "</p>";
        echo "<p><strong>Column Name:</strong> " . htmlspecialchars($row['column_name']) . "</p>";
        echo "<p><strong>Description:</strong> " . htmlspecialchars($row['description']) . "</p>";
    } else {
        echo "No details found for Activity ID: " . htmlspecialchars($activityId);
    }

    $stmt->close();
    $conn->close();
} else {
    echo "Error: Inquiry ID not provided.";
}
?>
