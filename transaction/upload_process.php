<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../style.css">
    <title>Upload Success</title>
    <style>
      body {
      background-image: url("../images/bg_booky.png");
      background-position: center;
      background-repeat: no-repeat;
      background-size: cover;
      background-attachment: fixed;
    }
    </style>
</head>
<?php
require_once("../header.php");
require_once("../inc/config.php");

// Function to convert date format
function convertDateFormat($dateString) {
    $date = DateTime::createFromFormat('F d, Y h:ia', $dateString);
    if ($date === false) {
        return null; // Handle invalid date format gracefully
    }
    return $date->format('Y-m-d H:i:s');
}

// Check if the file is uploaded
if (isset($_FILES['fileToUpload']['name']) && $_FILES['fileToUpload']['name'] != '') {
    $file_tmp = $_FILES['fileToUpload']['tmp_name'];

    $file_name_parts = explode('.', $_FILES['fileToUpload']['name']);
    $file_ext = strtolower(end($file_name_parts));
    $extensions = array("csv");

    // Check if the file extension is allowed
    if (in_array($file_ext, $extensions) === false) {
        echo "Extension not allowed, please choose a CSV file.";
        exit();
    }

    // Process CSV file and insert data into MySQL
    $handle = fopen($file_tmp, "r");
    $header = fgetcsv($handle); // Skip header row

    // Prepare MySQL statement for first table
    $stmt1 = $conn->prepare("INSERT INTO transaction (transaction_id, store_id, promo_code, customer_id, customer_name, transaction_date, gross_amount, discount, amount_discounted, payment, bill_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    while (($data = fgetcsv($handle)) !== FALSE) {
        // Remove double quotes from column 23
        $data[25] = str_replace('"', '', $data[25]);
        $data[11] = str_replace(',', '', $data[11]);
        $data[12] = str_replace(',', '', $data[12]);
        $data[13] = str_replace(',', '', $data[13]);
        // Convert date format for column 6 (transaction_date)
        $transaction_date = convertDateFormat($data[8]);

        // Bind and execute for first table
        $stmt1->bind_param("sssssssssss", $data[7], $data[3], $data[6], $data[5], $data[4], $transaction_date, $data[11], $data[12], $data[13], $data[25], $data[27]);
        $stmt1->execute();
    }

    fclose($handle);
?>
<body>
    <div class="container">
        <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
            <circle class="checkmark__circle" cx="26" cy="26" r="25"/>
            <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
        </svg>
        <h2 style="padding-top:10px;color: #4caf50;">Successfully uploaded!</h2>
        <a href="index.php"><button type="button" class="btn btn-secondary okay">Okay</button></a>
    </div>
    <script>
        setTimeout(function(){
            window.location.href = 'index.php';
        }, 3000); // Delay for 3 seconds (3000 milliseconds)
    </script>
</body>
</html>

<?php
} else {
    echo "No file uploaded.";
}
?>
