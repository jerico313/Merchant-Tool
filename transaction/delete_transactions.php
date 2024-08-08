<?php
include ("../inc/config.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if (isset($_POST['transaction_ids'])) {
    $transaction_ids = $_POST['transaction_ids'];

    $placeholders = rtrim(str_repeat('?,', count($transaction_ids)), ',');
    $sql = "DELETE FROM transaction WHERE transaction_id IN ($placeholders)";
    $stmt = $conn->prepare($sql);

    $types = str_repeat("s", count($transaction_ids)); // Adjust types if needed
    $stmt->bind_param($types, ...$transaction_ids);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
      echo 'Transactions deleted successfully.';
    } else {
      echo 'No transactions deleted.';
    }

    $stmt->close();
    $conn->close();
  } else {
    echo 'No transaction IDs provided.';
  }
} else {
  echo 'Invalid request method.';
}
?>
