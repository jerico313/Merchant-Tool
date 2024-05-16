<?php require_once("header.php")?>
<?php
function displayOrder() {
  include("inc/config.php");

  $sql = "SELECT * FROM transaction";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
      $count = 1;
      while ($row = $result->fetch_assoc()) {
          echo "<tr data-id='" . $row['order_id'] . "'>";
          echo "<td>" . $row['order_id'] . "</td>";
          echo "<td>" . $row['transaction_date'] . "</td>";
          echo "<td>" . $row['customer_name'] . "</td>";
          echo "<td>" . $row['customer_id'] . "</td>";
          echo "<td>" . $row['payment_status'] . "</td>";
          echo "<td>" . $row['payment'] . "</td>";
          echo "<td>" . $row['merchant_name'] . "</td>";
          echo "<td>" . $row['merchant_id'] . "</td>";
          echo "<td>" . $row['store_name'] . "</td>";
          echo "<td>" . $row['store_id'] . "</td>";
          echo "<td>" . $row['promo_codes'] . "</td>";
          echo "<td>" . $row['promo_type'] . "</td>";
          echo "<td>" . $row['claim_id'] . "</td>";
          
          echo "<td>" . number_format($row['voucher_price'], 2) . "</td>";
          echo "<td>" . number_format($row['total_actual_sales'], 2) . "</td>";
          echo "<td style='text-align:center;background-color:transparent;border-bottom: 1px solid #808080;'>";
          
          echo "</td>";
          echo "</tr>";
          $count++;
      }
  }

  $conn->close();
}
?>
<?php
function displayMerchant() {
  include("inc/config.php");

  $sql = "SELECT * FROM transaction";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
      $count = 1;
      while ($row = $result->fetch_assoc()) {
          echo "<tr data-uuid='" . $row['transaction_id'] . "'>";
          echo "<td style='text-align:center;'>" . $row['transaction_id'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['store_id'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['offer_id'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['customer_id'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['customer_name'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['claim_id'] . "</td>";
          echo "<td style='text-align:center;'>" . number_format($row['gross_sale'], 2) . "</td>";
          echo "<td style='text-align:center;'>" . number_format($row['discount'], 2) . "</td>";
          echo "<td style='text-align:center;'>" . $row['mode_of_payment'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['payment_status'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['pg_fee_id'] . "</td>";
          echo "<td style='text-align:center;'>";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;' onclick='editEmployee(" . $row['transaction_id'] . ")'>View</button> ";
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
<link rel='stylesheet' href='https://cdn.datatables.net/fixedcolumns/3.3.3/css/fixedColumns.bootstrap5.min.css'>
<script src='https://cdn.datatables.net/fixedcolumns/3.3.3/js/dataTables.fixedColumns.min.js'></script>
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
      color: #E96529;
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
      padding-bottom: 10px;
    }
  }
</style>
<script>
  function editEmployee(id) {
    window.location = "edit_order.php?order_id=" + id;
  }
</script>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-5">
    <div class="sub" style="text-align:left;">
      <div class="add-btns">
        <p class="title">Transaction</p>
        <!-- Form to upload file -->
        
        <a href="upload_transaction.php"><button type="button" class="btn btn-secondary check-report"><i class="fa-solid fa-upload"></i> Upload Orders</button></a>
        
      </div>
      <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
        <div class="table-container">
          <table id="example" class="table bord" style="width:250%;">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Transaction Date</th>
                <th>Customer Name</th>
                <th>Customer ID</th>
                <th>Payment Status</th>
                <th>Payment</th>
                <th>Merchant Name</th>
                <th>Merchant ID</th>
                <th>Store Name</th>
                <th>Store ID</th>
                <th>Promo Codes</th>
                <th>Promo Type</th>
                <th>Claim ID</th>
                <th>Gross Sale</th>
                <th>Voucher Price</th>
                <th>Total Actual Sales</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayOrder(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
<script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>

<script>
  // JavaScript to display filename and preview
  document.getElementById('fileToUpload').addEventListener('change', function() {
    const filenameElement = document.querySelector('.filename');
    const filename = this.files[0].name;
    filenameElement.textContent = `Selected file: ${filename}`;

    // Preview the file content
    const previewArea = document.querySelector('.file-preview');
    previewArea.innerHTML = ''; // Clear previous preview
    const file = this.files[0];
    if (file.type === 'application/vnd.ms-excel' || file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || file.name.endsWith('.csv')) {
      const reader = new FileReader();
      reader.onload = function(event) {
        const contents = event.target.result;
        const lines = contents.split('\n');
        const table = document.createElement('table');
        table.classList.add('table', 'table-bordered', 'mt-3');
        const tbody = document.createElement('tbody');
        for (let i = 0; i < Math.min(5, lines.length); i++) {
          const cells = lines[i].split(',');
          const row = document.createElement('tr');
          for (let j = 0; j < cells.length; j++) {
            const cell = document.createElement('td');
            cell.textContent = cells[j];
            row.appendChild(cell);
          }
          tbody.appendChild(row);
        }
        table.appendChild(tbody);
        previewArea.appendChild(table);
      }
      reader.readAsText(file);
    } else {
      const pElement = document.createElement('p');
      pElement.textContent = 'File preview not available';
      previewArea.appendChild(pElement);
    }
  });

  
</script>
<script>
$(document).ready(function() {
  if ( $.fn.DataTable.isDataTable('#example') ) {
    $('#example').DataTable().destroy();
  }
  
  $('#example').DataTable({
    scrollX: true
  });
});
</script>
<script>
</script>
</body>
</html>
