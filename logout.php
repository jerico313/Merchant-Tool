<?php
// Start the session
session_start();

// Destroy the session to log out the user
session_destroy();

// Redirect to the sign-in page
header("Location: index.php");
exit();
?>
