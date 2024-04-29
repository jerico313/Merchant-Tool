<?php include("header.php")?>
<?php
function displayMerchant() {
  include("inc/config.php");

  $sql = "SELECT * FROM merchant";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
      $count = 1;
      while ($row = $result->fetch_assoc()) {
          echo "<tr data-id='" . $row['merchant_id'] . "'>";
          echo "<td>" . $row['merchant_id'] . "</td>";
          echo "<td>" . $row['merchant_name'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['merchant_partnership_type'] . "</td>";
          echo "<td>" . $row['legal_entity_name'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['fulfillment_type'] . "</td>";
          echo "<td>" . $row['business_address'] . "</td>";
          echo "<td>" . $row['email_address'] . "</td>";
          echo "<td>" . $row['vat_type'] . "</td>";
          echo "<td style='text-align:center;'>";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;' onclick='editEmployee(" . $row['merchant_id'] . ")'>View</button> ";
          echo "</td>";
          echo "</tr>";
          $count++;
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
  <title>Homepage</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> 

  <style>
    body {
      background-image: url("images/bg.png");
      background-size: cover;
      background-repeat: no-repeat;
    }
    .page-item.active .page-link {
      z-index: 3;
      color: #fff;
      background-color: #E96529;
      border-color: #E96529;
    }
    .pagination{
      padding-bottom:10px;
    }
    .upload-btn {
      display: inline-block;
      background-color: #E96529;
      color:#fff;
      border: none;
      padding:5px;
      width:150px;
      border-radius: 20px;
      cursor: pointer;
      text-align: center;
    }
    .upload-btn:hover {
      background-color: #CD683B;
    }
    input[type="file"] {
      display: none;
    }
    </style>
  </style>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-5">
  <div class="sub" style="text-align:left;">
  
  <div class="reset" style="padding-bottom: 0px; padding-right: 30px; display: flex; align-items: center;">
    <p style="font-size: 30px; font-weight: bold; margin-right: auto; padding-left:30px;color:#E96529;">Merchants</p>
    <button type="button" class="btn btn-danger" style="border: none; border-radius: 20px;margin-right:10px; background-color: #E96529; width: 150px;"><i class="fa-solid fa-plus"></i> Add New Merchant</button>
    <form action="/upload" method="post" enctype="multipart/form-data">
            <label for="fileToUpload" class="upload-btn"><i class="fa-solid fa-upload"></i> Upload Merchant</label>
            <input type="file" name="fileToUpload" id="fileToUpload" accept=".csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel">
    </form>
</div>

    <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
        <table id="example" class="table bord">
        <thead>
            <tr>
                <th>Merchant ID</th>
                <th>Merchant Name</th>
                <th>Merchant Type</th>
                <th>Legal Entity Name</th>
                <th style="width:70px;">Fulfillment Type</th>
                <th>Business Address</th>
                <th>Email Address</th>
                <th>VAT Type</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="dynamicTableBody">
        <?php displayMerchant(); ?>
        </tbody>
    </table>
  </div>
</div>
</div>
<script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
<script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
<script src="./js/script.js"></script>
</body>
</html>