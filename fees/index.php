<?php
include_once ("../header.php");

function displayFee()
{
  global $conn, $type;
  $sql = "SELECT fee.*, merchant.merchant_name FROM fee INNER JOIN merchant ON fee.merchant_id = merchant.merchant_id";
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
      echo "<td style='display:none;'>" . $row['merchant_id'] . "</td>";
      $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
      echo "<td class='actions-cell;'>";
      echo "<button class='btn action-btn' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#F1F1F1;'></i></button>";
      echo "<div class='mt-2 actions-list' style='display:none;cursor:pointer;'>"; 
      echo "<ul class='list-group'>";
      if ($type !== 'User') {
        echo "<li class='list-group-item action-item'><a href='#' onclick='editFee(\"" . $row['fee_id'] . "\")' style='color:#E96529;pointer'>Edit</a></li>";
      }
      echo "<li class='list-group-item action-item'><a href='#' onclick='viewHistory(\"" . $row['fee_id'] . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;pointer'>View History</a></li>";
      echo "</ul>";
      echo "</div>";
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
                class="fa-solid fa-plus"></i> Add Fee</button></a>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:120%;">
            <thead>
              <tr>
                <th class="first-col">Fee ID</th>
                <th>Merchant Name</th>
                <th>Paymaya Credit Card</th>
                <th>Gcash</th>
                <th>Gcash Miniapp</th>
                <th>Paymaya</th>
                <th>Maya Checkout</th>
                <th>Maya</th>
                <th>Leadgen Commission</th>
                <th>Commission Type</th>
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


    <div class="modal fade" id="editFeeModal" data-bs-backdrop="static" tabindex="-1"
      aria-labelledby="editMerchantModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px;">
          <div class="modal-header border-0">
            <p class="modal-title" id="editMerchantModalLabel">Edit Fee Details</p>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <form id="editfeeForm" action="edit.php" method="POST">
              <input type="hidden" id="feeId" name="feeId">
              <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
              <input type="hidden" id="merchantId" name="merchantId">

              <div class="mb-3">
                <label for="paymayaCreditCard" class="form-label">Paymaya Credit Card, Maya Checkout, & Maya<span
                    class="text-danger" style="padding:2px">*</span></label>
                <div class="input-group">
                  <input type="number" step="0.01" class="form-control" id="paymayaCreditCard" name="paymayaCreditCard"
                    min="0.00" placeholder="0.00" required>
                  <span class="input-group-text">%</span>
                </div>
              </div>
              <div class="mb-3">
                <label for="gcash" class="form-label">Gcash<span class="text-danger"
                    style="padding:2px">*</span></label>
                <div class="input-group">
                  <input type="number" step="0.01" class="form-control" id="gcash" name="gcash" min="0.00"
                    placeholder="0.00" required>
                  <span class="input-group-text">%</span>
                </div>
              </div>
              <div class="mb-3">
                <label for="gcashMiniapp" class="form-label">Gcash Miniapp<span class="text-danger"
                    style="padding:2px">*</span></label>
                <div class="input-group">
                  <input type="number" step="0.01" class="form-control" id="gcashMiniapp" name="gcashMiniapp" min="0.00"
                    placeholder="0.00" required>
                  <span class="input-group-text">%</span>
                </div>
              </div>
              <div class="mb-3">
                <label for="paymaya" class="form-label">Paymaya<span class="text-danger"
                    style="padding:2px">*</span></label>
                <div class="input-group">
                  <input type="number" step="0.01" class="form-control" id="paymaya" name="paymaya" min="0.00"
                    placeholder="0.00" required>
                  <span class="input-group-text">%</span>
                </div>
              </div>
              <div class="mb-3">
                <label for="leadgenCommission" class="form-label">Leadgen Commission<span class="text-danger"
                    style="padding:2px">*</span></label>
                <div class="input-group">
                  <input type="number" step="0.01" class="form-control" id="leadgenCommission" name="leadgenCommission"
                    min="0.00" placeholder="0.00" required>
                  <span class="input-group-text">%</span>
                </div>
              </div>
              <div class="mb-3">
                <label for="commissionType" class="form-label">Commission Type<span class="text-danger"
                    style="padding:2px">*</span></label>
                <select class="form-select" id="commissionType" name="commissionType" required>
                  <option selected disabled>-- Select Commission Type --</option>
                  <option value="VAT Inc">VAT Inc</option>
                  <option value="VAT Exc">VAT Exc</option>
                </select>
              </div>
              <button type="submit" class="btn btn-primary modal-save-btn">Save changes</button>
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

      function viewHistory(fee_id, merchant_name) {
        window.location.href = 'history.php?fee_id=' + encodeURIComponent(fee_id) + '&merchant_name=' + encodeURIComponent(merchant_name);
      }

    </script>
    <script>
      function editFee(feeUuid) {
        var feeRow = $('#dynamicTableBody').find('tr[data-id="' + feeUuid + '"]');
        var paymayaCreditCard = feeRow.find('td:nth-child(3)').text().replace('%', '').trim();
        var gcash = feeRow.find('td:nth-child(4)').text().replace('%', '').trim();
        var gcashMiniapp = feeRow.find('td:nth-child(5)').text().replace('%', '').trim();
        var paymaya = feeRow.find('td:nth-child(6)').text().replace('%', '').trim();
        var mayaCheckout = feeRow.find('td:nth-child(7)').text().replace('%', '').trim();
        var maya = feeRow.find('td:nth-child(8)').text().replace('%', '').trim();
        var leadgenCommission = feeRow.find('td:nth-child(9)').text().replace('%', '').trim();
        var commissionType = feeRow.find('td:nth-child(10)').text();
        var merchantId = feeRow.find('td:nth-child(11)').text();

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

        $('#editFeeModal').modal('show');
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