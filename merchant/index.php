<?php include_once("../header.php"); ?>
<?php
function displayMerchant() {
  
  include_once("../inc/config.php");

  $sql = "SELECT * FROM merchant";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
      $count = 1;
      while ($row = $result->fetch_assoc()) {
          $shortMerchantId = substr($row['merchant_id'], 0, 8);
          echo "<tr data-uuid='" . $row['merchant_id'] . "' data-partnership-type='" . strtolower($row['merchant_partnership_type']) . "'>";
          echo "<td style='text-align:center;'>" . $shortMerchantId . "</td>";
          echo "<td style='text-align:center;'>" . $row['merchant_name'] . "</td>";
          echo "<td style='text-align:center;' class='partnership-type'>" . $row['merchant_partnership_type'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['merchant_type'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['business_address'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['email_address'] . "</td>";
          echo "<td style='text-align:center;'>";
          $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;' onclick='viewMerchant(\"" . $row['merchant_id'] . "\", \"" . $escapedMerchantName . "\")'>View</button> ";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#95DD59;color:black;' onclick='editMerchant(\"" . $row['merchant_id'] . "\")'>Edit</button> ";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:100px;background-color:#4BB0B8;color:#fff;padding:4px;' onclick='checkReport(\"" . $row['merchant_id'] . "\", \"" . $escapedMerchantName . "\"  )'>Check Report</button> ";
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
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js" integrity="sha384-oBqDVmMz4fnFO9gybB08pRA9KFNJ6i7rtCIL9W8IKOmG4CJoFtI03eZI7Ph9jGxi" crossorigin="anonymous"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js" integrity="sha384-mQ93qBRaUHnTwhWm6A98qE6pK6DdEDQNl7h4WBC5h85ibG/NHOoxuHV9r+lpazjl" crossorigin="anonymous"></script>
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
    }

    .add-btns {
      padding-bottom: 0px; 
      padding-right: 5vh; 
      display: flex; 
      align-items: center;
    }

    .modal-title {
      font-size: 15px;
    }

    table.dataTable tbody th:last-child,
    table.dataTable tbody td:last-child {
        position: sticky;
        right: 0;
        z-index: 2;
        background-color: #F1F1F1 !important;
        box-shadow: -4px 0px 5px 0px rgba(0,0,0,0.12);
        -webkit-box-shadow: -4px 0px 5px 0px rgba(0,0,0,0.12);
        -moz-box-shadow: -4px 0px 5px 0px rgba(0,0,0,0.12);
    }

    table thead th:last-child {
      position: sticky !important; 
      right: 0;
      z-index: 2;
      box-shadow: -4px 0px 5px 0px rgba(0,0,0,0.12);
      -webkit-box-shadow: -4px 0px 5px 0px rgba(0,0,0,0.12);
      -moz-box-shadow: -4px 0px 5px 0px rgba(0,0,0,0.12);
      width:15%;
    }

    select {
      background: transparent;
      border: 1px solid #ccc;
      padding: 5px;
      border-radius: 5px;
      color: #333;
      width:80px;
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
    <a href="settlement_report.php"><button type="button" class="btn btn-warning check-report" style="display:none;"><i class="fa-solid fa-print"></i> Check Report</button></a>
    <a href="upload.php"><button type="button" class="btn btn-warning add-merchant"><i class="fa-solid fa-plus"></i> Add Merchant</button></a>
  </div>

    <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
        <table id="example" class="table bord" style="width:150%;">
        <thead>
            <tr>
                <th>Merchant ID</th>
                <th>Merchant Name</th>
                <th>Merchant Partnership Type</th>
                <th>Merchant Type</th>
                <th>Business Address</th>
                <th>Email Address</th>
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
<!-- Edit Modal -->        
<div class="modal fade" id="editMerchantModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="editMerchantModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header border-0">
        <p class="modal-title" id="editMerchantModalLabel">Edit Merchant Details</p>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="editMerchantForm" action="edit.php" method="POST">
          <input type="hidden" id="merchantId" name="merchantId">
          <div class="mb-3">
            <label for="merchantName" class="form-label">Merchant Name</label>
            <input type="text" class="form-control" id="merchantName" name="merchantName">
          </div>
          <div class="mb-3">
              <label for="merchantPartnershipType" class="form-label">Merchant Partnership Type</label>
              <select class="form-select" id="merchantPartnershipType" name="merchantPartnershipType">
                <option value="Primary">Primary</option>
                <option value="Secondary">Secondary</option>
              </select>
            </div>
            <div class="mb-3">
              <label for="merchantType" class="form-label">Merchant Type</label>
              <select class="form-select" id="merchantType" name="merchantType">
              <option value="Grab & Go">Grab & Go</option>
              <option value="Casual Dining">Casual Dining</option>
              </select>
            </div>
          <div class="mb-3">
            <label for="businessAddress" class="form-label">Business Address</label>
            <input type="text" class="form-control" id="businessAddress" name="businessAddress">
          </div>
          <div class="mb-3">
            <label for="emailAddress" class="form-label">Email Address</label>
            <input type="text" class="form-control" id="emailAddress" name="emailAddress">
          </div>
        
      </div>
      <div class="modal-footer border-0">
        <button type="submit" class="btn btn-primary" style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save changes</button>
      </div>
      </form>
    </div>
  </div>
</div>
<!-- Modal for Checking Report -->
<div class="modal fade" id="checkReportModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="checkReportModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header border-0">
        <p class="modal-title" id="checkReportModalLabel">Check Report</p>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="checkReportForm">
            <input type="hidden" id="reportMerchantId">
            <div class="mb-3">
                <label for="reportType" class="form-label">Report Type</label>
                <select class="form-select" id="reportType" required>
                    <option value="" disabled>-- Select Report Type --</option>
                    <option value="Coupled">Coupled</option>
                    <option value="Decouple">Decouple</option>
                    <option value="GCash">GCash</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="startDate" class="form-label">Start Date</label>
                <input type="date" class="form-control" id="startDate" required>
            </div>
            <div class="mb-3">
                <label for="endDate" class="form-label">End Date</label>
                <input type="date" class="form-control" id="endDate" required>
            </div>
            <button type="button" class="btn btn-primary" style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;" onclick="submitReport()">Generate Report</button>
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
function editMerchant(merchantUuid) {
    // Fetch the current data of the selected merchant
    var merchantRow = $('#dynamicTableBody').find('tr[data-uuid="' + merchantUuid + '"]');
    var merchantName = merchantRow.find('td:nth-child(2)').text();
    var merchantPartnershipType = merchantRow.find('td:nth-child(3)').text();
    var merchantType = merchantRow.find('td:nth-child(4)').text();
    var businessAddress = merchantRow.find('td:nth-child(5)').text();
    var emailAddress = merchantRow.find('td:nth-child(6)').text();

    // Set values in the edit modal
    $('#merchantId').val(merchantUuid);
    $('#merchantName').val(merchantName);
    $('#merchantPartnershipType').val(merchantPartnershipType);
    $('#merchantType').val(merchantType);
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
</script>
<script>
$(document).ready(function() {
    if ($.fn.DataTable.isDataTable('#example')) {
        $('#example').DataTable().destroy();
    }
    
    $('#example').DataTable({
        scrollX: true,
        columnDefs: [
          { orderable: false, targets: [ 2, 3, 4, 5, 6] }    // Disable sorting for the first column
        ],
        order: []  // Ensure no initial ordering
    });
});

function checkReport(merchantId, merchantName) {
    // Set values in the check report modal
    $('#reportMerchantId').val(merchantId);
    $('#reportType').val(""); // Reset the report type

    // Open the check report modal
    $('#checkReportModal').modal('show');
}
</script>
</body>
</html>
