<?php
include_once ("../header.php");

function displayPGFeeRate()
{
  global $conn, $type;
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
      echo "<td style='text-align:center;display:none;'>" . $row['merchant_id'] . "</td>";
      $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
      echo "<td style='text-align:center;'>";

      // Check if user type is 'user' to hide edit button
      if ($type !== 'User') {
        echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:80px;background-color:#95DD59;color:black;' onclick='editFee(\"" . $row['fee_id'] . "\")'>Edit</button> ";
      }

      echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:80px;background-color:#E8C0AE;color:black;' onclick='viewHistory(\"" . $row['fee_id'] . "\", \"" . $escapedMerchantName . "\")'>View History</button>";
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
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
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

    .title {
      font-size: 30px;
      font-weight: bold;
      margin-right: auto;
      padding-left: 5vh;
      color: #E96529;
      "

    }

    .add-btns {
      padding-bottom: 0px;
      padding-right: 5vh;
      display: flex;
      align-items: center;
    }

    .modal-title {
      font-size: 15px;
      font-weight: bold;
    }

    .form-label {
      font-weight: bold;
    }

    @media only screen and (max-width: 767px) {

      table,
      thead,
      tbody,
      th,
      td,
      tr {
        display: block;
        text-align: left !important;
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
        text-align: left !important;
        font-weight: bold;
      }

      .table td:nth-child(1) {
        background: #E96529;
        height: 100%;
        top: 0;
        left: 0;
        font-weight: bold;
        color: #fff;
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

      .title {
        font-size: 25px;
        padding-left: 2vh;
        padding-top: 10px;
      }

      .add-btns {
        padding-right: 2vh;
      }
    }
  </style>
</head>

<body>
  <div class="cont-box">
    <div class="custom-box pt-4">
      <div class="sub" style="text-align:left;">

        <div class="add-btns">
          <p class="title">Fees</p>
          <a href="upload.php"><button type="button" class="btn btn-danger add-merchant"><i
                class="fa-solid fa-upload"></i> Upload Fees</button></a>
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
                <th style="display:none;"></th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayPGFeeRate(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Edit Modal -->
    <div class="modal fade" id="editFeeModal" data-bs-backdrop="static" tabindex="-1"
      aria-labelledby="editMerchantModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px;">
          <div class="modal-header border-0">
            <p class="modal-title" id="editMerchantModalLabel" style="font-size:15px;font-weight:bold;">Edit Fee Details
            </p>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <form id="editfeeForm" action="edit.php" method="POST">
              <input type="hidden" id="feeId" name="feeId">
              <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
              <input type="hidden" id="merchantId" name="merchantId">
              <div class="mb-3">
                <label for="paymayaCreditCard" class="form-label">Paymaya Credit Card, Maya Checkout, & Maya</label>
                <input type="text" class="form-control" id="paymayaCreditCard" name="paymayaCreditCard">
              </div>
              <div class="mb-3">
                <label for="gcash" class="form-label">GCash</label>
                <input type="text" class="form-control" id="gcash" name="gcash">
              </div>
              <div class="mb-3">
                <label for="gcashMiniapp" class="form-label">GCash Miniapp</label>
                <input type="text" class="form-control" id="gcashMiniapp" name="gcashMiniapp">
              </div>
              <div class="mb-3">
                <label for="paymaya" class="form-label">Paymaya</label>
                <input class="form-control" rows="3" id="paymaya" name="paymaya" style="padding:5px 5px;"
                  required></textarea>
              </div>
              <div class="mb-3">
                <label for="leadgenCommission" class="form-label">Leadgen Commission</label>
                <input class="form-control" rows="3" id="leadgenCommission" name="leadgenCommission"
                  style="padding:5px 5px;" required>
              </div>
              <div class="mb-3">
                <label for="commissionType" class="form-label">Commission Type</label>
                <select class="form-select" id="commissionType" name="commissionType" required>
                  <option value="VAT Inc">VAT Inc</option>
                  <option value="VAT Exc">VAT Exc</option>
                </select>
              </div>
              <button type="submit" class="btn btn-primary"
                style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save changes</button>
            </form>
          </div>
        </div>
      </div>
    </div>
    <script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
    <script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
    <script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
    <script src="./js/script.js"></script>
    <script>
      $(document).ready(function () {
        if ($.fn.DataTable.isDataTable('#example')) {
          $('#example').DataTable().destroy();
        }

        $('#example').DataTable({
          scrollX: true,
          columnDefs: [
            { orderable: false, targets: [2, 3, 4, 5, 6, 7, 8, 9, 10] }    // Disable sorting for the specified columns
          ],
          order: []  // Ensure no initial ordering
        });
      });

      function viewHistory(fee_id, merchant_name) {
        window.location.href = 'history.php?fee_id=' + encodeURIComponent(fee_id) + '&merchant_name=' + encodeURIComponent(merchant_name);
      }

    </script>
    <script>
      function editFee(feeUuid) {
        // Fetch the current data of the selected merchant
        var feeRow = $('#dynamicTableBody').find('tr[data-id="' + feeUuid + '"]');
        var paymayaCreditCard = feeRow.find('td:nth-child(3)').text();
        var gcash = feeRow.find('td:nth-child(4)').text();
        var gcashMiniapp = feeRow.find('td:nth-child(5)').text();
        var paymaya = feeRow.find('td:nth-child(6)').text();
        var mayaCheckout = feeRow.find('td:nth-child(7)').text();
        var maya = feeRow.find('td:nth-child(8)').text();
        var leadgenCommission = feeRow.find('td:nth-child(9)').text();
        var commissionType = feeRow.find('td:nth-child(10)').text();
        var merchantId = feeRow.find('td:nth-child(11)').text();

        // Set values in the edit modal
        $('#feeId').val(feeUuid);
        $('#paymayaCreditCard').val(paymayaCreditCard);
        $('#gcash').val(gcash);
        $('#gcashMiniapp').val(gcashMiniapp);
        $('#paymaya').val(paymaya);
        $('#mayaCheckout').val(mayaCheckout);
        $('#maya').val(maya);
        $('#leadgenCommission').val(leadgenCommission);
        $('#commissionType').val(commissionType);
        $('#merchantId').val(merchantId);

        // Open the edit modal
        $('#editFeeModal').modal('show');
      }
    </script>
    <script>
      // Get all inputs that need conversion
      const inputs = document.querySelectorAll('#paymayaCreditCard, #gcash, #gcashMiniapp, #paymaya, #leadgenCommission');

      // Add event listeners to each input
      inputs.forEach(input => {
        input.addEventListener('blur', function () {
          let value = this.value;

          // Check if the value is a number and if it's a whole number
          if (!isNaN(value) && Number.isInteger(parseFloat(value))) {
            // Convert the whole number to a decimal
            this.value = parseFloat(value).toFixed(2);
          }
        });
      });
    </script>
</body>

</html>