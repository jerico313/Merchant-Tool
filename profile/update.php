<?php
include ("../inc/config.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update_profile'])) {
    $name = $_POST['name'];
    $email = $_POST['email'];
    $user_id = $_POST['user_id'];

    $sql = "UPDATE user SET name = ?, email_address = ? WHERE user_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $name, $email, $user_id);

    if ($stmt->execute()) {
        header("Location: index.php");
        exit();
    } else {
        $alert = '<div id="alert-message" class="alert alert-danger" role="alert">Profile update failed!</div>';
        echo $alert; 
    }

    $stmt->close();
}
?>
