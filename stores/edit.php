<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    include("../inc/config.php");

    $storeId = $_POST['storeId'];
    $storeName = $_POST['storeName'];
    $legalEntityName = empty($_POST['legalEntityName']) ? NULL : $_POST['legalEntityName'];
    $storeAddress = empty($_POST['storeAddress']) ? NULL : $_POST['storeAddress'];
    $emailAddress = empty($_POST['emailAddress']) ? NULL : $_POST['emailAddress'];
    $merchantId = $_POST['merchantId'];
    $merchantName = $_POST['merchantName'];
    $userId = $_POST['userId'];

    $stmt = $conn->prepare("UPDATE store SET store_name=?, merchant_id=?, legal_entity_name=?, store_address=?, email_address=? WHERE store_id=?");
    $stmt->bind_param("ssssss", $storeName, $merchantId, $legalEntityName, $storeAddress, $emailAddress, $storeId);

    if ($stmt->execute()) {
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        $stmt->execute();
        $stmt->bind_result($latestActivityId);
        $stmt->fetch();
        $stmt->close();

        if ($latestActivityId) {
            $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
            $stmt->bind_param("ss", $userId, $latestActivityId);
            $stmt->execute();
            $stmt->close();
        }

        header("Location: index.php");
        exit();
    } else {
        error_log("Error updating record: " . $stmt->error);
        echo "An error occurred while updating the record. Please try again later.";
    }

    $stmt->close();
    $conn->close();
}
?>
