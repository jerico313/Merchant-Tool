<?php
include("../../../inc/config.php");

header('Content-Type: text/csv');
header('Content-Disposition: attachment;filename=transaction_view_history.csv');

$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';

$output = fopen('php://output', 'w');
fputcsv($output, array('Transaction ID', 'Transaction Date', 'Merchant ID', 'Merchant Name', 'Store ID', 'Store Name', 'Customer ID', 'Customer Name', 'Promo Code', 'Promo Cateogry', 'Promo Group', 'Promo Type', 'Gross Amount', 'Discount', 'Cart Amount', 'Mode of Payment', 'Bill Status', 'Commission Type', 'Commission Rate', 'Commission Amount', 'Total Billing', 'PG Fee Rate', 'PG Fee Amount', 'Amount to be Disbursed'));

$sql = "SELECT * FROM transaction_view_history WHERE `Store ID` = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $store_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        fputcsv($output, $row);
    }
}

fclose($output);
$conn->close();
?>

<?php
include("../../../inc/config.php");

$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';

header('Content-Type: text/csv');
header('Content-Disposition: attachment; filename="transaction_history.csv"');

$output = fopen('php://output', 'w');
fputcsv($output, array('Transaction ID', 'Transaction Date', 'Merchant ID', 'Merchant Name', 'Store ID', 'Store Name', 'Customer ID', 'Customer Name', 'Promo Code', 'Promo Cateogry', 'Promo Group', 'Promo Type', 'Gross Amount', 'Discount', 'Cart Amount', 'Mode of Payment', 'Bill Status', 'Commission Type', 'Commission Rate', 'Commission Amount', 'Total Billing', 'PG Fee Rate', 'PG Fee Amount', 'Amount to be Disbursed'));

$sql = "SHOW TABLES LIKE 'transaction_view_history'";
$result = $conn->query($sql);

if($result->num_rows == 1) {
    $sql = "SELECT * FROM transaction_view_history WHERE `Store ID` = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $store_id);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        fputcsv($output, $row);
    }

    $stmt->close();
} else {
    echo "Error: Table 'transaction_view_history' doesn't exist.";
}

fclose($output);
$conn->close();
?>
