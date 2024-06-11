<?php require_once("../header.php")?>

<?php
function displayPGFeeRate() {
  include("../inc/config.php");

  $sql = "SELECT fee.*, merchant.merchant_name FROM fee INNER JOIN merchant ON fee.merchant_id = merchant.merchant_id";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
      while ($row = $result->fetch_assoc()) {
          $shortFeeId = substr($row['fee_id'], 0, 8);
          echo "<tr data-id='" . $row['fee_id'] . "'>";
          echo "<td style='text-align:center;'>" . $shortFeeId . "</td>";
          echo "<td style='text-align:center;'>" . $row['merchant_name'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['paymaya_credit_card'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['gcash'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['gcash_miniapp'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['paymaya'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['maya_checkout'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['maya'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['lead_gen_commission'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['commission_type'] . "</td>";
          echo "</tr>";
      }
  }

  $conn->close();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> 
  <link rel="stylesheet" href="../style.css">

  <style>
    body {
      background-image: url("../images/bg_booky.png");
      background-position: center;
      background-repeat: no-repeat;
      background-size: cover;
      background-attachment: fixed;
    }

    .title{
      font-size: 30px; 
      font-weight: bold; 
      margin-right: auto; 
      padding-left: 5vh;
      color: #E96529;"
    }

    .add-btns{
      padding-bottom: 0px; 
      padding-right: 5vh; 
      display: flex; 
      align-items: center;
    }

    @media only screen and (max-width: 767px) {
    table,
    thead,
    tbody,
    th,
    td,
    tr {
      display: block;
      text-align:left !important;
    }

    thead tr,
    tfoot tr {
      position: absolute;
      top: -9999px;
      left: -9999px;
    }

    td {
      border: none;
      border-bottom: 1px solid #eee;
      position: relative;
      padding-left: 50% !important;
    }

    td:before {
      position: absolute;
      top: 6px;
      left: 6px;
      width: 45%;
      padding-right: 10px;
      white-space: nowrap;
      text-align:left !important;
      font-weight:bold;
    }

    .table td:nth-child(1) {
      background: #E96529;
      height: 100%;
      top: 0;
      left: 0;
      font-weight: bold;
      color:#fff;
    }

    td:nth-of-type(1):before {
      content: "Merchant ID";
    }

    td:nth-of-type(2):before {
      content: "Merchant Name";
    }

    td:nth-of-type(3):before {
      content: "Merchant Type";
    }

    td:nth-of-type(4):before {
      content: "Legal Entity Name";
    }

    td:nth-of-type(5):before {
      content: "Fullfillment Type";
    }

    td:nth-of-type(6):before {
      content: "Business Address";
    }

    td:nth-of-type(7):before {
      content: "Email Address";
    }

    td:nth-of-type(8):before {
      content: "VAT Type";
    }

    td:nth-of-type(9):before {
      content: "Commission ID";
    }

    td:nth-of-type(10):before {
      content: "Action";
    }

    .dataTables_length {
      display: none;
    }

    .title{
      font-size: 25px;
      padding-left: 2vh;
      padding-top:10px;
    }
  
    .add-btns{
      padding-right: 2vh; 
    }
}
    </style>
  </style>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-4">
  <div class="sub" style="text-align:left;">
  
  <div class="add-btns">
    <p class="title">Fee</p>
    <a href="upload_pg_fee_rate.php"><button type="button" class="btn btn-danger add-merchant"><i class="fa-solid fa-plus"></i> Add PG Fee Rate</button></a>
</div>

    <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
        <table id="example" class="table bord" style="width:100%;">
        <thead>
            <tr>
                <th>Fee ID</th>
                <th>Merchant Name</th>
                <th>Paymaya Credit Card</th>
                <th>GCash</th>
                <th>GCash Miniapp</th>
                <th>Paymaya</th>
                <th>Maya Checkout</th>
                <th>Maya</th>
                <th>Leadgen Commission</th>
                <th>Commission Type</th>
            </tr>
        </thead>
        <tbody id="dynamicTableBody">
        <?php displayPGFeeRate(); ?>
        </tbody>
    </table>
  </div>
</div>
</div>
<script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
<script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
<script src="./js/script.js"></script>
<script>
$(document).ready(function() {
    if ($.fn.DataTable.isDataTable('#example')) {
        $('#example').DataTable().destroy();
    }
    
    $('#example').DataTable({
        scrollX: true,
        columnDefs: [
          { orderable: false, targets: [ 2, 3, 4, 5, 6, 7, 8, 9] }    // Disable sorting for the first column
        ],
        order: []  // Ensure no initial ordering
    });
});
</script>
</body>
</html>