<?php
include_once ("../header.php");

function displayStore()
{
  global $conn, $type;
  $sql = "SELECT * FROM store_view";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $shortStoreId = substr($row['store_id'], 0, 8);
      $email_address_full = empty($row['email_address']) ? '-' : $row['email_address'];
      $email_address = strlen($row['email_address']) > 30 ? substr($row['email_address'], 0, 30) . '...' : $row['email_address'];

      echo "<tr style='padding:15px 0;' data-uuid='" . $row['store_id'] . "'>";
      echo "<td>" . $shortStoreId . "</td>";
      echo "<td>" . $row['store_name'] . "</td>";
      echo "<td style='display:none;'>" . $row['merchant_id'] . "</td>";
      echo "<td>" . $row['merchant_name'] . "</td>";
      echo "<td>" . $row['legal_entity_name'] . "</td>";
      echo "<td>" . $row['store_address'] . "</td>";
      echo "<td style='display:none;'>" . htmlspecialchars($email_address_full) . "</td>";
      echo "<td class='text-cell' data-full='" . htmlentities($email_address_full) . "' data-short='" . htmlentities($email_address) . "'>" . $email_address . "</td>";
      echo "<td>" . $row['cwt_rate'] ."%". "</td>";

      echo "<td class='actions-cell'>";
      echo "<button class='btn action-btn' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#F1F1F1;'></i></button>";
      echo "<div class='mt-2 actions-list' style='display:none;cursor:pointer;'>";
      echo "<ul class='list-group'>";
      $escapedStoreName = htmlspecialchars($row['store_name'], ENT_QUOTES, 'UTF-8');
      $escapedLegalEntityName = htmlspecialchars($row['legal_entity_name'], ENT_QUOTES, 'UTF-8');
      $escapedStoreAddress = empty($row['store_address']) ? '-' : htmlspecialchars($row['store_address'], ENT_QUOTES, 'UTF-8');
      if ($type !== 'User') {
        echo "<li class='list-group-item action-item'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View</a></li>";
        echo "<li class='list-group-item action-item'><a href='#' onclick='editStore(\"" . $row['store_id'] . "\")' style='color:#E96529;'>Edit</a></li>";
      } else {
        echo "<li class='list-group-item action-item'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View</a></li>";
      }
      echo "<li class='list-group-item action-item'><a href='#' onclick='checkReport(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\", \"" . $escapedLegalEntityName . "\", \"" . $escapedStoreAddress . "\")' style='color:#E96529;'>Check Report</a></li>";
      echo "<li class='list-group-item action-item'><a href='#' onclick='viewReport(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\", \"" . $escapedLegalEntityName . "\")' style='color:#E96529;'>View Reports</a></li>";
      echo "<li class='list-group-item action-item'><a href='#' onclick='viewHistory(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View History</a></li>";
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
  <title>Stores</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link rel="stylesheet" href="../style.css">
  <link rel="stylesheet" href="../responsive-table-styles/store.css">
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
          <p class="title">Stores</p>
          <a href="upload.php">
            <button type="button" class="btn btn-primary add-merchant">
              <i class="fa-solid fa-upload"></i> Upload Stores
            </button>
          </a>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:150%;">
            <thead>
              <tr>
                <th class="first-col" style="width:7%">Store ID</th>
                <th style="width:20%">Store Name</th>
                <th style="display:none;"></th>
                <th style="width:15%">Merchant Name</th>
                <th>Legal Entity Name</th>
                <th>Store Address</th>
                <th style="display:none;"></th>
                <th>Email Address</th>
                <th>CWT Rate</th>
                <th class="action-col" style="width:6%">Actions</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayStore(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div class="modal fade" id="editStoreModal" data-bs-backdrop="static" tabindex="-1"
      aria-labelledby="editStoreModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px;">
          <div class="modal-header border-0">
            <p class="modal-title" id="editStoreModalLabel">Edit Store Details</p>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <form id="editStoreForm" action="edit.php" method="POST">
              <input type="hidden" id="storeId" name="storeId">
              <input type="hidden" id="merchantId" name="merchantId">
              <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">

              <div class="mb-3">
                <label for="storeName" class="form-label">
                  Store Name<span class="text-danger" style="padding:2px">*</span>
                </label>
                <input type="text" class="form-control" id="storeName" name="storeName" placeholder="Enter store name"
                  required maxlength="255">
              </div>
              <div class="mb-3">
                <label for="merchantName" class="form-label">
                  Merchant Name<span class="text-danger" style="padding:2px">*</span>
                </label>
                <input type="text" class="form-control" id="merchantName" name="merchantName"
                  style="background-color: #d3d3d3; caret-color: transparent;" placeholder="Enter merchant name"
                  required readonly>
              </div>
              <div class="mb-3">
                <label for="legalEntityName" class="form-label">Legal Entity Name</label>
                <input type="text" class="form-control" id="legalEntityName" name="legalEntityName"
                  placeholder="Enter legal entity name" maxlength="255">
              </div>
              <div class="mb-3">
                <label for="storeAddress" class="form-label">Store Address</label>
                <textarea type="text" class="form-control" id="storeAddress" name="storeAddress"
                  placeholder="Enter store address" rows="2"></textarea>
              </div>
              <div class="mb-3">
                <label for="emailAddress" class="form-label">Email Address</label>
                <textarea type="text" class="form-control" id="emailAddress" name="emailAddress"
                  placeholder="Enter email address" rows="2"></textarea>
              </div>
              <div class="mb-3">
                <label for="CWT Rate" class="form-label">CWT Rate<span class="text-danger"
                  style="padding:2px">*</span></label>
                <div class="input-group">
                <input type="number" step="0.01" class="form-control" id="cwtRate" name="cwtRate"
                  min="0.00" placeholder="0.00" required>
                <span class="input-group-text">%</span>
                </div>
              </div>
              <button type="submit" class="btn btn-primary modal-save-btn">Save changes</button>
            </form>
          </div>
        </div>
      </div>
    </div>
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
                        <input type="hidden" id="reportStoreId" name="storeId">
                        <input type="hidden" id="reportStoreName" name="storeName">
                        <input type="hidden" id="merchantId" name="merchantId"
                            value="<?php echo htmlspecialchars($merchant_id); ?>">
                        <input type="hidden" id="merchantName" name="merchantName"
                            value="<?php echo htmlspecialchars($merchant_name); ?>">
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
                        <button type="button" class="btn btn-primary modal-save-btn" id="submitReport">Generate
                            Report</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
    <script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
    <script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
    <script>
      $(window).on('load', function () {
        $('.loading').hide();
        $('.cont-box').show();

        var table = $('#example').DataTable({
          scrollX: true,
          columnDefs: [
            { orderable: false, targets: [0, 5, 6, 7, 8] }
          ],
          order: [[1, 'asc']]
        });
      });
    </script>


    <script>
      function editStore(storeId) {
        var storeRow = $('#dynamicTableBody').find('tr[data-uuid="' + storeId + '"]');
        var storeName = storeRow.find('td:nth-child(2)').text();
        var merchantId = storeRow.find('td:nth-child(3)').text();
        var merchantName = storeRow.find('td:nth-child(4)').text();
        var legalEntityName = storeRow.find('td:nth-child(5)').text();
        var storeAddress = storeRow.find('td:nth-child(6)').text();
        var emailAddress = storeRow.find('td:nth-child(7)').text();
        var cwtRate = storeRow.find('td:nth-child(9)').text().replace('%', '').trim();

        // Set values in the edit modal
        $('#storeId').val(storeId);
        $('#storeName').val(storeName);
        $('#merchantId').val(merchantId);
        $('#merchantName').val(merchantName);
        $('#cwtRate').val(cwtRate);

        if (legalEntityName === '-') {
          $('#legalEntityName').val(null);
        } else {
          $('#legalEntityName').val(legalEntityName);
        }

        if (storeAddress === '-') {
          $('#storeAddress').val(null);
        } else {
          $('#storeAddress').val(storeAddress);
        }

        if (emailAddress === '-') {
          $('#emailAddress').val(null);
        } else {
          $('#emailAddress').val(emailAddress);
        }

        $('#editStoreModal').modal('show');
      }

      function viewOrder(storeId, storeName) {
        window.location.href = 'transactions/index.php?store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
      }

      function viewReport(storeId, storeName) {
            window.location.href = 'reports/index.php?store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
        }

      function viewHistory(storeId, storeName) {
        window.location.href = 'history.php?store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
      }
    </script>

    <script>
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
      function toggleActions(button) {
        var actionsList = button.nextElementSibling;
        if (actionsList.style.display === 'none' || actionsList.style.display === '') {
          actionsList.style.display = 'block';
        } else {
          actionsList.style.display = 'none';
        }
      }
    </script>
     <script>
        function checkReport(storeId, storetName) {
            document.getElementById('reportStoreId').value = storeId;
            document.getElementById('reportStoreName').value = storeName;

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

            form.method = 'POST';

            form.submit();
        });
    </script>
</body>
</html>