<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("inc/config.php");

    // Retrieve the form data
    $storeId = $_POST['storeId'];
    $storeName = $_POST['storeName'];
    $storeAddress = $_POST['storeAddress'];
    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];

    // Prepare the SQL statement
    $stmt = $conn->prepare("UPDATE store SET store_name=?, store_address=? WHERE store_id=?");
    $stmt->bind_param("sss", $storeName, $storeAddress, $storeId);

    // Execute the statement and check for errors
    if ($stmt->execute()) {
        // Redirect to the store page with the merchant_id and merchant_name after a successful update
        header("Location: store.php?merchant_id=" . urlencode($merchantId) . "&merchant_name=" . urlencode($merchantName));
        exit();
    } else {
        // Output an error message if something goes wrong
        echo "Error updating record: " . $stmt->error;
    }

    // Close the statement and connection
    $stmt->close();
    $conn->close();
}
?>
