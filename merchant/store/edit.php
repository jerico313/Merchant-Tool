<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../../inc/config.php");

    // Retrieve the form data
    $storeId = $_POST['storeId'];
    $storeName = $_POST['storeName'];
    $legalEntityName = $_POST['legalEntityName'];
    $storeAddress = $_POST['storeAddress'];
    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];

    // Prepare the SQL statement
    $stmt = $conn->prepare("UPDATE store SET store_name=?, merchant_id=?, legal_entity_name=?, store_address=? WHERE store_id=?");
    $stmt->bind_param("sssss", $storeName, $merchantId, $legalEntityName, $storeAddress, $storeId);

    // Execute the statement and check for errors 
    if ($stmt->execute()) {
        // Redirect to the store page with the merchant_id and merchant_name after a successful update
        header("Location: index.php?merchant_id=" . htmlspecialchars($merchantId) . "&merchant_name=" . htmlspecialchars($merchantName));
        exit();
    } else {
        // Log error message
        error_log("Error updating record: " . $stmt->error);
        echo "An error occurred while updating the record. Please try again later.";
    }

    // Close the statement and connection
    $stmt->close();
    $conn->close();
}
?>
