<?php
include ("../inc/config.php");
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['transaction_ids'])) {
        $transaction_ids = $_POST['transaction_ids'];

        $placeholders = rtrim(str_repeat('?,', count($transaction_ids)), ',');
        $sql = "DELETE FROM transaction WHERE transaction_id IN ($placeholders)";
        $stmt = $conn->prepare($sql);

        $types = str_repeat("s", count($transaction_ids));
        $stmt->bind_param($types, ...$transaction_ids);
        $stmt->execute();

        if ($stmt->affected_rows > 0) {
            echo 'Transactions deleted successfully.';

            $userId = $_SESSION['user_id'];
            $update_stmt = $conn->prepare("
                UPDATE activity_history
                SET user_id = ?
                WHERE (user_id IS NULL OR user_id = '')
                AND activity_type = 'Delete'
            ");
            $update_stmt->bind_param("s", $userId);
            $update_stmt->execute();
            $update_stmt->close();

            header("Location: index.php");
            exit();
        } else {
            echo 'No transactions deleted.';
        }

        $stmt->close();
    } else {
        echo 'No transaction IDs provided.';
    }

    $conn->close();
} else {
    echo 'Invalid request method.';
}
?>
