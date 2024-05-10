<?php
require_once("inc/config.php");

if(isset($_FILES['fileToUpload']['name']) && $_FILES['fileToUpload']['name'] != ''){
  $file_name = $_FILES['fileToUpload']['name'];
  $file_tmp = $_FILES['fileToUpload']['tmp_name'];

  $file_ext = strtolower(end(explode('.',$_FILES['fileToUpload']['name'])));
  $extensions = array("csv");

  if(in_array($file_ext,$extensions) === false){
    echo "Extension not allowed, please choose a CSV file.";
    exit();
  }

  move_uploaded_file($file_tmp,"uploads/".$file_name);
  
  // Process CSV file and insert data into MySQL
  $csvFile = "uploads/".$file_name;
  $handle = fopen($csvFile, "r");
  $header = fgetcsv($handle); // Skip header row
  
  // Prepare MySQL statement
  $stmt = $conn->prepare("INSERT INTO orders (transaction_date, customer_name, customer_id, orders_id,payment_status, payment, merchant_name) VALUES ( ?, ?, ?, ?, ?, ?, ?)");
  
  while (($data = fgetcsv($handle)) !== FALSE) {
    $stmt->bind_param("sssssss", $data[0], $data[1], $data[2], $data[3], $data[4], $data[5], $data[6]);
    $stmt->execute();
  }
  
  fclose($handle);
  
  header("Location: order.php");
  exit();
} else {
  echo "No file uploaded.";
}
?>
