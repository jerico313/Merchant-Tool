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
          echo "<td style='text-align:center;'>" . $row['business_address'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['email_address'] . "</td>";
          echo "<td style='text-align:center;'>";
          $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;' onclick='viewMerchant(\"" . $row['merchant_id'] . "\", \"" . $escapedMerchantName . "\")'>View</button> ";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#95DD59;color:black;' onclick='editMerchant(\"" . $row['merchant_id'] . "\")'>Edit</button> ";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:100px;background-color:#4BB0B8;color:#fff;padding:4px;' onclick='checkReport(\"" . $row['merchant_id'] . "\", \"" . $escapedMerchantName . "\"  )'>Check Report</button> ";
          echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:100px;background-color:#E31C21;color:#fff;padding:4px;' onclick='viewReport(\"" . $row['merchant_id'] . "\", \"" . $escapedMerchantName . "\"  )'>View Report</button> ";
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
        <table id="example" class="table bord" style="width:150%;height:auto;">
        <thead>
            <tr>
                <th>Merchant ID</th>
                <th>Merchant Name</th>
                <th>Merchant Partnership Type</th>
                <th>Business Address</th>
                <th>Email Address</th>
                <th style="width:220px;">Action</th>
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
              <label for="merchantPartnershipType" class="form-label">Partnership Type</label>
              <select class="form-select" id="merchantPartnershipType" name="merchantPartnershipType">
                <option value="Primary">Primary</option>
                <option value="Secondary">Secondary</option>
              </select>
            </div>
          <div class="mb-3">
            <label for="businessAddress" class="form-label">Business Address</label>
            <input type="text" class="form-control" id="businessAddress" name="businessAddress">
          </div>
          <div class="mb-3">
            <label for="emailAddress" class="form-label">Email Address</label>
            <input type="email" class="form-control" id="emailAddress" name="emailAddress">
          </div>
          <button type="submit" class="btn btn-primary" style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save changes</button>
        </form>
      </div>
    </div>
  </div>
</div>
<!-- Report Modal -->
<div class="modal fade" id="reportModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="reportModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header border-0">
        <p class="modal-title" id="reportModalLabel">Choose Report Type</p>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="reportForm">
          <input type="hidden" id="reportMerchantId" name="merchantId">
          <input type="hidden" id="reportMerchantId" name="merchantId">
          <input type="hidden" id="reportMerchantName" name="merchantName">
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
          <button type="button" class="btn btn-primary" style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;" id="submitReport">Generate Report</button>
        </form>
      </div>
    </div>
  </div>
</div>
<div id="alertContainer"></div>


<script>
  $(document).ready(function () {
    $('#example').DataTable({
      scrollX: true
    });
  });

  function checkReport(uuid, merchantName) {
    $('#reportMerchantId').val(uuid);
    $('#reportMerchantName').val(merchantName); 
    $('#reportModal').modal('show');
  }

  $('#submitReport').on('click', function () {
  var merchantId = $('#reportMerchantId').val();
  var reportType = $('#reportType').val();
  var startDate = $('#startDate').val();
  var endDate = $('#endDate').val();
  var url;

  if (reportType === 'Coupled') {
    url = 'coupled_generate_report.php';
  } else if (reportType === 'Decoupled') {
    url = 'decoupled_generate_report.php';
  } else if (reportType === 'GCash') {
    url = 'gcash_generate_report.php';
  }

  $.ajax({
    url: url,
    type: 'POST',
    data: { merchant_id: merchantId, start_date: startDate, end_date: endDate },
    success: function (response) {
      console.log(response);

      // Hide the modal first
      $('#reportModal').modal('hide');

      // Create custom alert
      var customAlert = $('<div class="alert-custom alert alert-success" role="alert" style="height:250px; display: flex; flex-direction: column; justify-content: center; align-items: center; padding-top:30px;">' +
                          '<span><i class="fa-solid fa-circle-check fa-xl" style="font-size:80px;"></i></span>' +
                          '<span><p style="padding-top:50px; font-size:15px;">Report generated successfully!</p></span>' +
                          '</div>');

      // Append the custom alert to a specific location, e.g., at the top of the page or a specific container
      $('#alertContainer').append(customAlert);

      var merchantName = $('#dynamicTableBody').find('tr[data-uuid="' + merchantId + '"]').find('td:nth-child(2)').text();
      // Redirect after a short delay
      setTimeout(function() {
        window.location.href = 'settlement_reports.php?merchant_id=' + merchantId + '&merchant_name=' + encodeURIComponent(merchantName);
      }, 3000); // Delay of 3 seconds before redirection
    },
    error: function (xhr, status, error) {
      console.error('Error:', error);
      $('#reportModal').modal('hide');
    }
  });
});
</script>
<script>
function editMerchant(merchantUuid) {
    // Fetch the current data of the selected merchant
    var merchantRow = $('#dynamicTableBody').find('tr[data-uuid="' + merchantUuid + '"]');
    var merchantName = merchantRow.find('td:nth-child(2)').text();
    var merchantPartnershipType = merchantRow.find('td:nth-child(3)').text();
    var businessAddress = merchantRow.find('td:nth-child(4)').text();
    var emailAddress = merchantRow.find('td:nth-child(5)').text();

    // Set values in the edit modal
    $('#merchantId').val(merchantUuid);
    $('#merchantName').val(merchantName);
    $('#merchantPartnershipType').val(merchantPartnershipType);
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
    window.location.href = 'settlement_reports.php?merchant_id=' + encodeURIComponent(merchantId) + '&merchant_name=' + encodeURIComponent(merchantName);
}
</script>
<script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
</body>
</html>


