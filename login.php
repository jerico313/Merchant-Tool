<?php
require_once 'inc/config.php'; // Include the config file to access database credentials

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Validate input (you can add more validation)

    // Check if the database connection is established
    if ($conn) {
        // Prepare and bind statement
        $stmt = $conn->prepare("SELECT * FROM users WHERE email_address = ?");
        $stmt->bind_param("s", $email);

        // Execute the statement
        $stmt->execute();
        
        // Get result
        $result = $stmt->get_result();
        
        // Check if user exists
        if ($result->num_rows == 1) {
            // Fetch user data
            $user = $result->fetch_assoc();
            // Verify password
            if (password_verify($password, $user['password'])) {
                // Password is correct, redirect to dashboard or homepage
                header("Location: home.php");
                exit();
            } else {
                // Password is incorrect
                echo "Incorrect password";
            }
        } else {
            // User not found
            echo "User not found";
        }

        // Close statement and connection
        $stmt->close();
    } else {
        echo "Database connection failed";
    }
}
?>
