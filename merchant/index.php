<?php
include_once("../header.php");

function displayMerchant()
{
    global $conn, $type;
    $sql = "SELECT * FROM merchant_view";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortMerchantId = substr($row['merchant_id'], 0, 8);
            $shortSalesId = substr($row['sales_id'], 0, 8);
            $shortAccountManagerId = substr($row['account_manager_id'], 0, 8);

            echo "<tr data-uuid='" . $row['merchant_id'] . "'>";
            echo "<td style='text-align:center;'>" . $shortMerchantId . "</td>";
            echo "<td style='text-align:center;'>" . htmlspecialchars($row['merchant_name']) . "</td>";
            echo "<td style='text-align:center;'>" . htmlspecialchars($row['legal_entity_name']) . "</td>";
            echo "<td style='text-align:center;'>" . htmlspecialchars($row['business_address']) . "</td>";
            echo "<td style='text-align:center;'>" . htmlspecialchars($row['email_address']) . "</td>";
            echo "<td style='text-align:center;'>" . $shortSalesId . "</td>";
            echo "<td style='text-align:center;'>" . htmlspecialchars($row['sales']) . "</td>";
            echo "<td style='text-align:center;'>" . $shortAccountManagerId . "</td>";
            echo "<td style='text-align:center;'>" . htmlspecialchars($row['account_manager']) . "</td>";
            echo "<td style='text-align:center;' class='actions-cell'>"; 
            echo "<button class='btn' style='border:none;background-color:transparent;border-radius:10px;' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:20px;color:#4BB0B8;padding-top:3px;'></i></button>";

            // Action list (initially hidden)
            echo "<div class='mt-2 actions-list' style='display:none;'>"; // Hidden initially
            echo "<ul class='list-group'>";
            
            $escapedMerchantId = htmlspecialchars($row['merchant_id'], ENT_QUOTES, 'UTF-8');
            $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
            
            if ($type !== 'User') {
                echo "<li class='list-group-item action-item' style='animation-delay: 0.1s;'><a href='#' onclick='viewMerchant(\"" . $escapedMerchantId . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>View</a></li>";
                echo "<li class='list-group-item action-item' style='animation-delay: 0.2s;'><a href='#' onclick='editMerchant(\"" . $escapedMerchantId . "\")' style='color:#E96529;'>Edit</a></li>";
            } else {
                echo "<li class='list-group-item action-item' style='animation-delay: 0.1s;'><a href='#' onclick='viewMerchant(\"" . $escapedMerchantId . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>View</a></li>";
            }
            
            echo "<li class='list-group-item action-item' style='animation-delay: 0.3s;'><a href='#' onclick='checkReport(\"" . $escapedMerchantId . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>Check Report</a></li>";
            echo "<li class='list-group-item action-item' style='animation-delay: 0.4s;'><a href='#'  onclick='viewReport(\"" . $escapedMerchantId  . "\", \"" . $escapedMerchantName . "\")' style='color:#E96529;'>View Report</a></li> ";
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
  <title>Homepage</title>
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
      background-position: center;
      background-repeat: no-repeat;
      background-size: cover;
      background-attachment: fixed;
    }
    @keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.action-item {
  animation: fadeIn 0.3s ease forwards;
}

    .title {
      font-size: 30px;
      font-weight: bold;
      margin-right: auto;
      padding-left: 5vh;
      color: #E96529;
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


    table.dataTable tbody th:last-child,
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
      box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12);
      -webkit-box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12);
      -moz-box-shadow: -4px 0px 5px 0px rgba(0, 0, 0, 0.12);
    }

    select {
      background: transparent;
      border: 1px solid #ccc;
      padding: 5px;
      border-radius: 5px;
      color: #333;
      width: 80px;
    }

    select:focus {
      outline: none;
      box-shadow: none;
    }
  </style>
</head>

<body>
  <div class="cont-box">
    <div class="custom-box pt-4">
      <div class="sub" style="text-align:left;">

        <div class="add-btns">
          <p class="title">Merchants</p>
          <a href="settlement_report.php"><button type="button" class="btn btn-warning check-report"
              style="display:none;"><i class="fa-solid fa-print"></i> Check Report</button></a>
          <a href="upload.php"><button type="button" class="btn btn-warning add-merchant"><i
                class="fa-solid fa-plus"></i> Add Merchant</button></a>
        </div>

        <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
          <table id="example" class="table bord" style="width:200%;height:auto;">
            <thead>
              <tr>
                <th>Merchant ID</th>
                <th style="width:150px !important;">Merchant Name</th>
                <th style="width:150px !important;">Legal Entity Name</th>
                <th style="width:250px !important;">Business Address</th>
                <th style="width:150px !important;">Email Address</th>
                <th>Sales ID</th>
                <th style="width:150px !important;">Sales</th>
                <th style="width:80px !important;">Account Manager ID</th>
                <th style="width:150px !important;">Account Manager</th>
                <th style="width:50px !important;">Action</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayMerchant(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Edit Modal -->
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
                <label for="merchantName" class="form-label">Merchant Name</label>
                <input type="text" class="form-control" id="merchantName" name="merchantName">
              </div>
              <div class="mb-3">
                <label for="merchantPartnershipType" class="form-label">Partnership Type</label>
                <select class="form-select" id="merchantPartnershipType" name="merchantPartnershipType">
                  <option value="Primary">Primary</option>
                  <option value="Secondary">Secondary</option>
                </select>
              </div>
              <div class="mb-3">
                <label for="legalEntityName" class="form-label">Legal Entity Name</label>
                <input type="text" class="form-control" id="legalEntityName" name="legalEntityName">
              </div>
              <div class="mb-3">
                <label for="businessAddress" class="form-label">Business Address</label>
                <input type="text" class="form-control" id="businessAddress" name="businessAddress">
              </div>
              <div class="mb-3">
                <label for="emailAddress" class="form-label">Email Address</label>
                <textarea class="form-control" rows="3" id="emailAddress" name="emailAddress" style="padding:5px 5px;"
                  required></textarea>
              </div>
              <button type="submit" class="btn btn-primary"
                style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save changes</button>
            </form>
          </div>
        </div>
      </div>
    </div>
    <!-- Report Modal -->
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
                <label for="reportType" class="form-label">Report Type</label>
                <select class="form-select" id="reportType" required>
                  <option selected disabled>-- Select Report Type --</option>
                  <option value="Coupled">Coupled</option>
                  <option value="Decoupled">Decoupled</option>
                  <option value="GCash">GCash</option>
                </select>
              </div>
              <div class="mb-3">
                <label for="startDate" class="form-label">Start Date</label>
                <input type="date" class="form-control" id="startDate" name="startDate" required>
              </div>
              <div class="mb-3">
                <label for="endDate" class="form-label">End Date</label>
                <input type="date" class="form-control" id="endDate" name="endDate" required>
              </div>
              <button type="button" class="btn btn-primary"
                style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;"
                id="submitReport">Generate Report</button>
            </form>
          </div>
        </div>
      </div>
    </div>
    <div id="alertContainer"></div>
    <script>
  function checkReport(merchantId, merchantName) {
    // Set the merchantId and merchantName in the report modal
    document.getElementById('reportMerchantId').value = merchantId;
    document.getElementById('reportMerchantName').value = merchantName;

    // Show the report modal
    $('#reportModal').modal('show');
  }

  document.getElementById('submitReport').addEventListener('click', function() {
    var form = document.getElementById('reportForm');
    var reportType = document.getElementById('reportType').value;

    if (reportType === 'Coupled') {
      form.action = 'coupled_generate_report.php';
    } else if (reportType === 'Decoupled') {
      form.action = 'decoupled_generate_report.php';
    } else if (reportType === 'GCash') {
      form.action = 'gcash_generate_report.php';
    }

    // Set the method to POST
    form.method = 'POST';

    form.submit();
  });
</script>

    <script>
      $(document).ready(function () {
        $('#example').DataTable({
          scrollX: true
        });
      });

      </script>
    <script>
      function editMerchant(merchantUuid) {
        // Fetch the current data of the selected merchant
        var merchantRow = $('#dynamicTableBody').find('tr[data-uuid="' + merchantUuid + '"]');
        var merchantName = merchantRow.find('td:nth-child(2)').text();
        var merchantPartnershipType = merchantRow.find('td:nth-child(3)').text();
        var legalEntityName = merchantRow.find('td:nth-child(4)').text();
        var businessAddress = merchantRow.find('td:nth-child(5)').text();
        var emailAddress = merchantRow.find('td:nth-child(6)').text();

        // Set values in the edit modal
        $('#merchantId').val(merchantUuid);
        $('#merchantName').val(merchantName);
        $('#merchantPartnershipType').val(merchantPartnershipType);
        $('#legalEntityName').val(legalEntityName);
        $('#businessAddress').val(businessAddress);
        $('#emailAddress').val(emailAddress);

        // Open the edit modal
        $('#editMerchantModal').modal('show');
      }
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

    <script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
</body>

</html>