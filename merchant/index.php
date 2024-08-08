<?php
include_once ("../header.php");

function displayMerchant()
{
  global $conn, $type;
  $sql = "SELECT * FROM merchant_view";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $shortMerchantId = substr($row['merchant_id'], 0, 8);

      // Prepare truncated and full text for email_address
      $email_address_full = $row['email_address'];
      $email_address = strlen($row['email_address']) > 30 ? substr($row['email_address'], 0, 30) . '...' : $row['email_address'];

      echo "<tr style='padding:15px 0;' data-uuid='" . $row['merchant_id'] . "'>";
      echo "<td>" . $shortMerchantId . "</td>";
      echo "<td>" . htmlspecialchars($row['merchant_name']) . "</td>";
      echo "<td>" . htmlspecialchars($row['merchant_partnership_type']) . "</td>";
      echo "<td>" . htmlspecialchars($row['legal_entity_name']) . "</td>";
      echo "<td>" . htmlspecialchars($row['business_address']) . "</td>";
      echo "<td style='display:none;'>" . htmlspecialchars($email_address_full) . "</td>";
      echo "<td class='text-cell' data-full='" . htmlentities($email_address_full) . "' data-short='" . htmlentities($email_address) . "'>" . $email_address . "</td>";
      echo "<td>" . htmlspecialchars($row['sales']) . "</td>";
      echo "<td>" . htmlspecialchars($row['account_manager']) . "</td>";
      echo "<td class='actions-cell'>";
      echo "<button class='btn action-btn' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#F1F1F1;'></i></button>";
      echo "<div class='mt-2 actions-list' style='display:none;'>"; // Hidden initially
      echo "<ul class='list-group'>";

      $escapedMerchantId = htmlspecialchars($row['merchant_id'], ENT_QUOTES, 'UTF-8');
      $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');

      if ($type !== 'User') {
        echo "<li class='list-group-item action-item'><a href='#' onclick='viewMerchant(\"" . $escapedMerchantId . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>View</a></li>";
        echo "<li class='list-group-item action-item'><a href='#' onclick='editMerchant(\"" . htmlspecialchars($row['merchant_id'], ENT_QUOTES, 'UTF-8') . "\")' style='color:#E96529;'>Edit</a></li>";
      } else {
        echo "<li class='list-group-item action-item'><a href='#' onclick='viewMerchant(\"" . $escapedMerchantId . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>View</a></li>";
      }

      echo "<li class='list-group-item action-item'><a href='#' onclick='checkReport(\"" . $escapedMerchantId . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>Check Report</a></li>";
      echo "<li class='list-group-item action-item'><a href='#'  onclick='viewReport(\"" . $escapedMerchantId . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>View Reports</a></li> ";
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
  <title>Merchants</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js"
    integrity="sha384-oBqDVmMz4fnFO9gybB08pRA9KFNJ6i7rtCIL9W8IKOmG4CJoFtI03eZI7Ph9jGxi"
    crossorigin="anonymous"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"
    integrity="sha384-mQ93qBRaUHnTwhWm6A98qE6pK6DdEDQNl7h4WBC5h85ibG/NHOoxuHV9r+lpazjl"
    crossorigin="anonymous"></script>
  <link rel="stylesheet" href="../style.css">

  <style>
    body {
      background-image: url("../images/bg_booky.png");
    }

    #alertContainer {
      position: fixed;
      top: 0;
      left: 50%;
      transform: translateX(-50%);
      z-index: 1000;
      margin-top: 15%;
      width: 300px;
      padding: 15px;
      font-size: 13px;
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

    .loading {
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 80vh;
      font-size: 18px;
      color: #333;
      font-weight: 800;
    }

    .cont-box {
      display: none;
    }


    .lds-default,
    .lds-default div {
      box-sizing: border-box;
    }

    .lds-default {
      display: inline-block;
      position: relative;
      width: 80px;
      height: 80px;
      color: #E96529;
    }

    .lds-default div {
      position: absolute;
      width: 6.4px;
      height: 6.4px;
      background: currentColor;
      border-radius: 50%;
      animation: lds-default 1.2s linear infinite;
    }

    .lds-default div:nth-child(1) {
      animation-delay: 0s;
      top: 36.8px;
      left: 66.24px;
    }

    .lds-default div:nth-child(2) {
      animation-delay: -0.1s;
      top: 22.08px;
      left: 62.29579px;
    }

    .lds-default div:nth-child(3) {
      animation-delay: -0.2s;
      top: 11.30421px;
      left: 51.52px;
    }

    .lds-default div:nth-child(4) {
      animation-delay: -0.3s;
      top: 7.36px;
      left: 36.8px;
    }

    .lds-default div:nth-child(5) {
      animation-delay: -0.4s;
      top: 11.30421px;
      left: 22.08px;
    }

    .lds-default div:nth-child(6) {
      animation-delay: -0.5s;
      top: 22.08px;
      left: 11.30421px;
    }

    .lds-default div:nth-child(7) {
      animation-delay: -0.6s;
      top: 36.8px;
      left: 7.36px;
    }

    .lds-default div:nth-child(8) {
      animation-delay: -0.7s;
      top: 51.52px;
      left: 11.30421px;
    }

    .lds-default div:nth-child(9) {
      animation-delay: -0.8s;
      top: 62.29579px;
      left: 22.08px;
    }

    .lds-default div:nth-child(10) {
      animation-delay: -0.9s;
      top: 66.24px;
      left: 36.8px;
    }

    .lds-default div:nth-child(11) {
      animation-delay: -1s;
      top: 62.29579px;
      left: 51.52px;
    }

    .lds-default div:nth-child(12) {
      animation-delay: -1.1s;
      top: 51.52px;
      left: 62.29579px;
    }

    @keyframes lds-default {

      0%,
      20%,
      80%,
      100% {
        transform: scale(1);
      }

      50% {
        transform: scale(1.5);
      }
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
          <p class="title">Merchants</p>
          <a href="upload.php">
            <button type="button" class="btn btn-primary add-merchant">
              <i class="fa-solid fa-plus"></i> Add Merchant
            </button>
          </a>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:150%;height:auto;">
            <thead>
              <tr>
                <th class="first-col">Merchant ID</th>
                <th>Merchant Name</th>
                <th>Partnership Type</th>
                <th>Legal Entity Name</th>
                <th>Business Address</th>
                <th style="display:none;"></th>
                <th>Email Address</th>
                <th>Sales</th>
                <th>Account Manager</th>
                <th class="action-col" style="width:7%;">Actions</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayMerchant(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal: Edit Merchant Details -->
    <div class="modal fade" id="editMerchantModal" data-bs-backdrop="static" tabindex="-1"
      aria-labelledby="editMerchantModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px;">
          <div class="modal-header border-0">
            <p class="modal-title" id="editMerchantModalLabel">Edit Merchant Details</p>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <form id="editMerchantForm" action="edit.php" method="POST">
              <input type="hidden" id="merchantId" name="merchantId">
              <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">

              <div class="mb-3">
                <label for="merchantName" class="form-label">
                  Merchant Name<span class="text-danger" style="padding:2px">*</span>
                </label>
                <input type="text" class="form-control" id="merchantName" name="merchantName"
                  placeholder="Enter merchant name" required maxlength="255">
              </div>
              <div class="mb-3">
                <label for="merchantParntershipType" class="form-label">
                  Partnership Type<span class="text-danger" style="padding:2px">*</span>
                </label>
                <select class="form-select" id="merchantParntershipType" name="merchantParntershipType">
                  <option selected disabled>-- Select Partnership Type --</option>
                  <option value="Primary">Primary</option>
                  <option value="Secondary">Secondary</option>
                  <option value="Unknown partnership type">Unknown partnership type</option>
                </select>
              </div>
              <div class="mb-3">
                <label for="legalEntityName" class="form-label">Legal Entity Name</label>
                <input type="text" class="form-control" id="legalEntityName" name="legalEntityName"
                  placeholder="Enter legal entity name" maxlength="255">
              </div>
              <div class="mb-3">
                <label for="businessAddress" class="form-label">Business Address</label>
                <textarea class="form-control" rows="2" id="businessAddress" name="businessAddress"
                  placeholder="Enter business address"></textarea>
              </div>
              <div class="mb-3">
                <label for="emailAddress" class="form-label">Email Address</label>
                <textarea class="form-control" rows="3" id="emailAddress" name="emailAddress" style="padding:5px 5px;"
                  placeholder="Enter email address"></textarea>
              </div>
              <div class="mb-3">
                <label for="sales" class="form-label">
                  Sales
                </label>
                <input type="text" class="form-control" id="sales" name="sales"
                  placeholder="Enter sales person (leave blank if no assigned person)" maxlength="255">
              </div>
              <div class="mb-3">
                <label for="accountManager" class="form-label">
                  Account Manager
                </label>
                <input type="text" class="form-control" id="accountManager" name="accountManager"
                  placeholder="Enter account manager (leave blank if no assigned person)" maxlength="255">
              </div>
              <button type="submit" class="btn btn-primary modal-save-btn">Save changes</button>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal: Check Report -->
    <div class="modal fade" id="reportModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="reportModalLabel"
      aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px;">
          <div class="modal-header border-0">
            <p class="modal-title" id="reportModalLabel">Choose Report Type</p>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <form id="reportForm">
              <input type="hidden" id="reportMerchantId" name="merchantId">
              <input type="hidden" id="reportMerchantName" name="merchantName">
              <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
              <div class="mb-3">
                <label for="reportType" class="form-label">
                  Report Type<span class="text-danger" style="padding:2px">*</span>
                </label>
                <select class="form-select" id="reportType" required>
                  <option selected disabled>-- Select Report Type --</option>
                  <option value="Coupled">Coupled</option>
                  <option value="Decoupled">Decoupled</option>
                  <option value="Gcash">Gcash</option>
                </select>
              </div>
              <div class="mb-3">
                <label for="billStatus" class="form-label">
                  Bill Status<span class="text-danger" style="padding:2px">*</span>
                </label>
                <select class="form-select" id="billStatus" name="billStatus" required>
                  <option selected disabled>-- Select Bill Status --</option>
                  <option value="All">PRE-TRIAL and BILLABLE</option>
                  <option value="PRE-TRIAL">PRE-TRIAL</option>
                  <option value="BILLABLE">BILLABLE</option>
                </select>
              </div>
              <div class="mb-3">
                <label for="startDate" class="form-label">
                  Start Date<span class="text-danger" style="padding:2px">*</span>
                </label>
                <input type="date" class="form-control" id="startDate" name="startDate" required>
              </div>
              <div class="mb-3">
                <label for="endDate" class="form-label">
                  End Date<span class="text-danger" style="padding:2px">*</span>
                </label>
                <input type="date" class="form-control" id="endDate" name="endDate" required>
              </div>
              <button type="button" class="btn btn-primary modal-save-btn" id="submitReport">Generate Report</button>
            </form>
          </div>
        </div>
      </div>
    </div>
    <div id="alertContainer"></div>
    <script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>

    <!-- Script: Check Report -->
    <script>
      function checkReport(merchantId, merchantName) {
        // Set the merchantId and merchantName in the report modal
        document.getElementById('reportMerchantId').value = merchantId;
        document.getElementById('reportMerchantName').value = merchantName;

        // Show the report modal
        $('#reportModal').modal('show');
      }

      document.getElementById('submitReport').addEventListener('click', function () {
        var form = document.getElementById('reportForm');
        var reportType = document.getElementById('reportType').value;
        var billStatus = document.getElementById('billStatus').value;

        if (reportType === 'Coupled') {
          if (billStatus === 'PRE-TRIAL') {
            form.action = 'coupled_generate_report_pre-trial.php';
          } else if (billStatus === 'BILLABLE') {
            form.action = 'coupled_generate_report_billable.php';
          } else if (billStatus === 'All') {
            form.action = 'coupled_generate_report.php';
          }
        } else if (reportType === 'Decoupled') {
          if (billStatus === 'PRE-TRIAL') {
            form.action = 'decoupled_generate_report_pre-trial.php';
          } else if (billStatus === 'BILLABLE') {
            form.action = 'decoupled_generate_report_billable.php';
          } else if (billStatus === 'All') {
            form.action = 'decoupled_generate_report.php';
          }
        } else if (reportType === 'Gcash') {
          if (billStatus === 'PRE-TRIAL') {
            form.action = 'gcash_generate_report_pre-trial.php';
          } else if (billStatus === 'BILLABLE') {
            form.action = 'gcash_generate_report_billable.php';
          } else if (billStatus === 'All') {
            form.action = 'gcash_generate_report.php';
          }
        }

        // Set the method to POST
        form.method = 'POST';

        form.submit();
      });
    </script>

    <!-- Script: DataTable -->
    <script>
      $(window).on('load', function () {
        $('.loading').hide();
        $('.cont-box').show();

        var table = $('#example').DataTable({
          scrollX: true,
          columnDefs: [
            { orderable: false, targets: [0, 2, 5, 6, 9] }
          ],
          order: [[1, 'asc']]
        });
      });

    </script>

    <!-- Script: Edit Merchant Details -->
    <script>
      function editMerchant(merchantUuid) {
        // Fetch the current data of the selected merchant
        var merchantRow = $('#dynamicTableBody').find('tr[data-uuid="' + merchantUuid + '"]');
        var merchantName = merchantRow.find('td:nth-child(2)').text();
        var merchantParntershipType = merchantRow.find('td:nth-child(3)').text();
        var legalEntityName = merchantRow.find('td:nth-child(4)').text();
        var businessAddress = merchantRow.find('td:nth-child(5)').text();
        var emailAddress = merchantRow.find('td:nth-child(6)').text();
        var sales = merchantRow.find('td:nth-child(8)').text();  // Corrected index for salesId
        var accountManager = merchantRow.find('td:nth-child(9)').text();  // Corrected index for accountManagerId

        // Set values in the edit modal
        $('#merchantId').val(merchantUuid);
        $('#merchantName').val(merchantName);
        $('#merchantParntershipType').val(merchantParntershipType);

        if (legalEntityName === '-') {
          $('#legalEntityName').val(null);
        } else {
          $('#legalEntityName').val(legalEntityName);
        }

        if (businessAddress === '-') {
          $('#businessAddress').val(null);
        } else {
          $('#businessAddress').val(businessAddress);
        }

        if (emailAddress === '-') {
          $('#emailAddress').val(null);
        } else {
          $('#emailAddress').val(emailAddress);
        }

        if (sales === 'No assigned person') {
          $('#sales').val(null);
        } else {
          $('#sales').val(sales);
        }

        if (accountManager === 'No assigned person') {
          $('#accountManager').val(null);
        } else {
          $('#accountManager').val(accountManager);
        }

        // Open the edit modal
        $('#editMerchantModal').modal('show');
      }
    </script>

    <script>
      // Event delegation for text toggle of email address
      document.body.addEventListener('click', function (event) {
        if (event.target.classList.contains('text-cell')) {
          var fullText = event.target.getAttribute('data-full');
          var shortText = event.target.getAttribute('data-short');
          if (event.target.innerText === shortText) {
            event.target.innerText = fullText;
          } else {
            event.target.innerText = shortText;
          }
        }
      });
    </script>

    <script>
      function viewMerchant(merchantId, merchantName) {
        window.location.href = 'store/index.php?merchant_id=' + encodeURIComponent(merchantId) + '&merchant_name=' + encodeURIComponent(merchantName);
      }

      function viewReport(merchantId, merchantName) {
        window.location.href = 'reports/index.php?merchant_id=' + encodeURIComponent(merchantId) + '&merchant_name=' + encodeURIComponent(merchantName);
      }
    </script>
    <script>
      function toggleActions(button) {
        // Find the actions-list div relative to the button
        var actionsList = button.nextElementSibling;

        // Toggle the display style of the actions-list div
        if (actionsList.style.display === 'none') {
          actionsList.style.display = 'block';
        } else {
          actionsList.style.display = 'none';
        }
      }
    </script>
</body>

</html>