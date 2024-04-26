<?php include("header.php")?>
<?php
function displayStore() {
  include("inc/config.php");

  $sql = "SELECT * FROM store";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
      $count = 1;
      while ($row = $result->fetch_assoc()) {
          echo "<tr data-id='" . $row['store_id'] . "'>";
          echo "<td><center><input type='checkbox' style='accent-color:#E96529;' class='store-checkbox' value='" . $row['store_id'] . "'></center></td>";
          echo "<td>" . $row['store_id'] . "</td>";
          echo "<td>" . $row['merchant_id'] . "</td>";
          echo "<td>" . $row['store_name'] . "</td>";
          echo "<td>" . $row['store_address'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['commission_rate'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['vat_type'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['fulfillment_type'] . "</td>";
          echo "<td style='text-align:center;'>";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;' onclick='editEmployee(" . $row['store_id'] . ")'>View</button> ";
          echo "<button class='btn btn-danger btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#95DD59;color:black;' onclick='deleteEmployee(" . $row['store_id'] . ")'>Checks</button> ";
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
  </style>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-5">
  <div class="sub" style="text-align:left;">
  
  <div class="voucher-type" style="padding-bottom: 0px; padding-right: 5vh; display: flex; align-items: center;">
  <p style="font-size: 30px; font-weight: bold; margin-right: auto; padding-left:5vh;color:#E96529;">Store</p>
    <button type="button" class="btn btn-danger" id="resetStatusButton" style="border: none; border-radius: 20px; background-color: #E96529; width: 110px;">COUPLED</button>
    <button type="button" class="btn btn-danger" id="resetTrainButton" style="border: none; border-radius: 20px; margin-left: 10px; background-color: #E96529; width: 110px;">DECOUPLED</button>
    <button type="button" class="btn btn-danger" id="resetTrainButton" style="border: none; border-radius: 20px; margin-left: 10px; background-color: #E96529; width: 110px;">GCASH</button>
</div>


    <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
        <table id="example" class="table bord">
        <thead>
            <tr>
                <th><center><input type="checkbox" style="accent-color:#E96529;" class="store-checkbox" id="checkAll"></center></th>
                <th>Merchant ID</th>
                <th>Store ID</th>
                <th>Store Name</th>
                <th>Store Address</th>
                <th>Commision Rate</th>
                <th>VAT Type</th>
                <th>Fulfillment Types </th>
                <th style="width:110px;">Action</th>
            </tr>
        </thead>
        <tbody id="dynamicTableBody">
        <?php displayStore(); ?>
        </tbody>
    </table>
    <div class="check" style="padding: 10px 0px 20px 0px; text-align: right;">
    <button type="button" class="btn btn-danger" id="resetStatusButton" style="border: none; background-color: #E96529; width:180px;">Checks Settlement Report</button>
</div>
  </div>
</div>
</div>
<script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
<script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
<script src="./js/script.js"></script>
<script>
  $(document).ready(function(){
    $('#checkAll').change(function(){
      $('.store-checkbox').prop('checked', $(this).prop('checked'));
    });
  });
</script>
</body>
</html>