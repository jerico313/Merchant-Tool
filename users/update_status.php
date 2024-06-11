<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $userId = $_POST['userId'];
  $status = $_POST['status'];

  include("../inc/config.php");

  $sql = "UPDATE user SET status = '$status' WHERE user_id = '$userId'";
  if ($conn->query($sql) === TRUE) {
      echo "Status updated successfully";
  } else {
      echo "Error updating status: " . $conn->error;
  }

  $conn->close();
}
?>