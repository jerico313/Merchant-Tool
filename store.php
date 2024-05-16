<?php include("header.php")?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

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
          echo "<td>" . $row['legal_entity_id'] . "</td>";
          echo "<td>" . $row['store_name'] . "</td>";
          echo "<td>" . $row['store_address'] . "</td>";
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
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> 
  <link rel="stylesheet" href="style.css">

  <style>
    body {
      background-image: url("images/bg_booky.png");
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
    

    .voucher-type{
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
      font-weight:bold;
      text-align:left !important;
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
      content: "Store ID";
    }

    td:nth-of-type(2):before {
      content: "Merchant ID";
    }

    td:nth-of-type(3):before {
      content: "Store Name";
    }

    td:nth-of-type(4):before {
      content: "Store Address";
    }

    td:nth-of-type(5):before {
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
  
    .voucher-type{
      padding-right: 2vh; 
    }
}
  </style>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-5">
  <div class="sub" style="text-align:left;">
  
  <div class="voucher-type">
  <div class="row pb-2 title" aria-label="breadcrumb" >
  <nav aria-label="breadcrumb">
    <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
        <li class="breadcrumb-item"><a href="<?php echo isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : '/'; ?>" style="color:#E96529; font-size:14px;"><?php echo $merchant_name; ?></a></li>
        <li class="breadcrumb-item dropdown">
            <a href="#" class="dropdown-toggle" role="button" id="storeDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="color:#E96529;font-size:14px;">
            Offers
            </a>
            <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                <li><a class="dropdown-item" href="#">Stores</a></li>
                <li><a class="dropdown-item" href="#">Category</a></li>
            </ul>
        </li>
    </ol>
</nav>
<p class="title_store" style="font-size:30px;">Store</p>
</div>
<button type="button" class="btn btn-warning check-report" style="display:none;"><i class="fa-solid fa-print"></i> Check Report</button>
    <button type="button" class="btn btn-warning add-merchant"><i class="fa-solid fa-plus"></i> Add Store</button>
</div>


    <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
        <table id="example" class="table bord">
        <thead>
            <tr>
                <th><center><input type="checkbox" style="accent-color:#E96529;" class="store-checkbox" id="checkAll"></center></th>
                <th>Store ID</th>
                <th>Merchant ID</th>
                <th>Legal Entity Name</th>
                <th>Store Name</th>
                <th>Store Address</th>
                <th style="width:110px;">Action</th>
            </tr>
        </thead>
        <tbody id="dynamicTableBody">
        <?php displayStore(); ?>
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
  $(document).ready(function(){
    $('#checkAll').change(function(){
      $('.store-checkbox').prop('checked', $(this).prop('checked'));
    });
  });
</script>
<script>
  $(document).ready(function(){
    $('#checkAll').change(function(){
      $('.store-checkbox').prop('checked', $(this).prop('checked'));
      toggleCheckReportButton();
    });

    $('.store-checkbox').change(function(){
      toggleCheckReportButton();
    });

    function toggleCheckReportButton() {
      if ($('.store-checkbox:checked').length > 0) {
        $('.check-report').show();
      } else {
        $('.check-report').hide();
      }
    }
  });
</script>
</body>
</html>