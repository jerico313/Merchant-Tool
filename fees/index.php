<?php
include_once("../header.php");

function displayFee()
{
  global $conn, $type;
  $sql = "SELECT * FROM fee_latest_view";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $shortFeeId = substr($row['fee_id'], 0, 8);

      echo "<tr data-id='" . $row['fee_id'] . "'>";
      echo "<td>" . $shortFeeId . "</td>";
      echo "<td>" . $row['merchant_name'] . "</td>";
      echo "<td>" . $row['paymaya_credit_card'] . "%" . "</td>";
      echo "<td>" . $row['gcash'] . "%" . "</td>";
      echo "<td>" . $row['gcash_miniapp'] . "%" . "</td>";
      echo "<td>" . $row['paymaya'] . "%" . "</td>";
      echo "<td>" . $row['maya_checkout'] . "%" . "</td>";
      echo "<td>" . $row['maya'] . "%" . "</td>";
      echo "<td>" . $row['lead_gen_commission'] . "%" . "</td>";
      echo "<td>" . $row['commission_type'] . "</td>";
      echo "<td>" . $row['effective_date'] . "</td>";
      echo "<td style='display:none;'>" . $row['merchant_id'] . "</td>";
      $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
      echo "<td>";
      echo "<a href='#' onclick='viewHistory(\"" . $escapedMerchantName . "\", \"" . $row['merchant_id'] . "\")' style='color:#E96529;pointer'>View History</a>";
      echo "</td>";
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
  <title>Fees</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link rel="stylesheet" href="../style.css">
  <link rel="stylesheet" href="../responsive-table-styles/fee.css">
  <style>
    body {
      background-image: url("../images/bg_booky.png");
    }

    table.dataTable tbody td:last-child {
      position: sticky;
      right: 0;
      z-index: 2;
      background-color: #F1F1F1 !important;
      box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12);
      -webkit-box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12);
      -moz-box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12);
    }

    table thead th:last-child {
      position: sticky !important;
      right: 0;
      z-index: 2;
      box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12) !important;
      -webkit-box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12) !important;
      -moz-box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12) !important;
    }
  </style>
</head>

<body>
  <div class="loading">
    <div>
      <div class="lds-default">
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
      </div>
    </div>
    Loading...
  </div>
  <div class="cont-box">
    <div class="custom-box pt-4">
      <div class="sub" style="text-align:left;">

        <div class="add-btns">
          <p class="title">Fees</p>
          <a href="upload.php"><button type="button" class="btn btn-danger add-merchant"><i
                class="fa-solid fa-upload"></i> Upload Fees</button></a>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:120%;">
            <thead>
              <tr>
                <th class="first-col">Fee ID</th>
                <th width="12%">Merchant Name</th>
                <th width="10%">Paymaya Credit Card</th>
                <th>Gcash</th>
                <th>Gcash Miniapp</th>
                <th>Paymaya</th>
                <th>Maya Checkout</th>
                <th>Maya</th>
                <th width="10%">Leadgen Commission</th>
                <th>Commission Type</th>
                <th>Effective Date</th>
                <th style="display:none;"></th>
                <th class="action-col" style="width:8%;">Action</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayFee(); ?>
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
      $(window).on('load', function () {
        $('.loading').hide();
        $('.cont-box').show();

        $('#example').DataTable({
          scrollX: true,
          columnDefs: [
            { orderable: false, targets: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] }
          ],
          order: [[1, 'asc']]
        });
      });

      function viewHistory(merchant_name, merchant_id) {
        window.location.href = 'history.php?merchant_name=' + encodeURIComponent(merchant_name) + '&merchant_id=' + encodeURIComponent(merchant_id);
      }
    </script>
    
    <script>
      const inputs = document.querySelectorAll('#paymayaCreditCard, #gcash, #gcashMiniapp, #paymaya, #leadgenCommission');
      inputs.forEach(input => {
        input.addEventListener('blur', function () {
          let value = this.value;

          if (!isNaN(value) && Number.isInteger(parseFloat(value))) {
            this.value = parseFloat(value).toFixed(2);
          }
        });
      });
    </script>
    <script>
      function toggleActions(button) {
        var actionsList = button.nextElementSibling;

        if (actionsList.style.display === 'none') {
          actionsList.style.display = 'block';
        } else {
          actionsList.style.display = 'none';
        }
      }
    </script>
</body>

</html>