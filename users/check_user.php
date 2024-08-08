<?php
include('../inc/config.php'); // Include your config.php file with the database connection details

// Get the email from the AJAX request
$email = $_POST['email'];

// Check if the email exists in your database
$sql = "SELECT * FROM user WHERE email_address = '$email'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  // Email exists, send the 'exists' response
  echo "exists";
} else {
  // Email doesn't exist, send a different response (you can use 'not exists' or any other string)
  echo "not exists";
}

$conn->close();
?>