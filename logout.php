<?php
session_start();
session_destroy();
header("Location: /Merchant-Tool/");
exit();
?>
