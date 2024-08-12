<?php
include('../inc/config.php');

$email = $_POST['email'];

$sql = "SELECT * FROM user WHERE email_address = '$email'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  echo "exists";
} else {
  echo "not exists";
}

$conn->close();
?>