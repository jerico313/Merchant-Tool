<?php 
include_once("../../header.php");

$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

function displayStore($merchant_id) {
    global $conn, $type;

    $sql = "SELECT store.*, merchant.merchant_name
            FROM store
            JOIN merchant ON store.merchant_id = merchant.merchant_id
            WHERE store.merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortStoreId = substr($row['store_id'], 0, 8);
            echo "<tr data-uuid='" . $row['store_id'] . "'>";
            echo "<td style='text-align:center;'>" . $shortStoreId . "</td>";
            echo "<td style='text-align:center;'>" . $row['store_name'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['legal_entity_name'] . "</td>"; // Assuming legal_entity_name is a column in store table now
            echo "<td style='text-align:center;'>" . $row['store_address'] . "</td>";
            echo "<td style='text-align:center;'>";

            // Initialize variables for HTML output
            $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
            $escapedStoreName = htmlspecialchars($row['store_name'], ENT_QUOTES, 'UTF-8');
            $escapedLegalEntityName = htmlspecialchars($row['legal_entity_name'], ENT_QUOTES, 'UTF-8');
            $escapedStoreAddress = htmlspecialchars($row['store_address'], ENT_QUOTES, 'UTF-8');

            // Display buttons based on user type
            if ($type !== 'User') {
                echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;padding:4px;' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\")'>View</button> ";
                echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#95DD59;color:black;padding:4px;' onclick='editStore(\"" . $row['store_id'] . "\")'>Edit</button> ";
            } else {
                echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;padding:4px;' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\")'>View</button> ";
            }

            echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:100px;background-color:#4BB0B8;color:#fff;padding:4px;' onclick='checkReport(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\", \"" . $escapedLegalEntityName . "\", \"" . $escapedStoreAddress . "\")'>Check Report</button> ";
            echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:100px;background-color:#E31C21;color:#fff;padding:4px;' onclick='viewReport(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\", \"" . $escapedLegalEntityName . "\")'>View Report</button> ";
            echo "</td>";
            echo "</tr>";
        }
    }

    $stmt->close();
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
    <link rel="stylesheet" href="../../style.css">
    <style>
        body {
            background-image: url("../../images/bg_booky.png");
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
            color: #4BB0B8;
        }
        .voucher-type {
            padding-bottom: 0px; 
            padding-right: 5vh; 
            display: flex; 
            align-items: center;
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
                font-weight: bold;
                text-align: left !important;
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
            .title {
                font-size: 25px;
                padding-left: 2vh;
                padding-top: 10px;
            }
            .voucher-type {
                padding-right: 2vh; 
            }
        }
    </style>
</head>
<body>
<div class="cont-box">
    <div class="custom-box pt-4">
        <div class="sub" style="text-align:left;">
            <div class="voucher-type">
                <div class="row pb-2 title" aria-label="breadcrumb">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                            <li class="breadcrumb-item"><a href="../index.php" style="color:#E96529; font-size:14px;">Merchant</a></li>
                            <li class="breadcrumb-item dropdown">
                                <a href="#" class="dropdown-toggle" role="button" id="storeDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="color:#E96529;font-size:14px;">
                                Store
                                </a>
                                <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                    <li><a class="dropdown-item" href="../promo/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" data-breadcrumb="Offers">Promo</a></li>
                                    <li><a class="dropdown-item" href="../settlement_reports.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" data-breadcrumb="Offers">Settlement Reports</a></li>                                
                                </ul>
                            </li>
                        </ol>
                    </nav>
                    <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);"><?php echo htmlspecialchars($merchant_name); ?></p>
                </div>
                <button type="button" class="btn btn-warning check-report mt-4" style="display:none;"><i class="fa-solid fa-print"></i> Check Report</button>
                <a href="upload.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"><button type="button" class="btn btn-warning add-merchant mt-4"><i class="fa-solid fa-plus"></i> Add Store</button></a>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:100%;">
                    <thead>
                        <tr>
                            <th style="width:50px;">Store ID</th>
                            <th>Store Name</th>
                            <th>Legal Entity Name</th>
                            <th>Store Address</th>
                            <th style='width:350px;'>Action</th>
                        </tr>
                    </thead>
                    <tbody id="dynamicTableBody">
                    <?php displayStore($merchant_id); ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<!-- Modal for Editing Store Details -->
<div class="modal fade" id="editStoreModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="editStoreModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header border-0">
        <p class="modal-title" id="editStoreModalLabel">Edit Store Details</p>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="editStoreForm" action="edit.php" method="POST">
            <input type="hidden" id="storeId" name="storeId">
            <input type="hidden" id="merchantId" name="merchantId" value="<?php echo htmlspecialchars($merchant_id); ?>">
            <input type="hidden" id="merchantName" name="merchantName" value="<?php echo htmlspecialchars($merchant_name); ?>">
            <div class="mb-3">
                <label for="storeName" class="form-label">Store Name</label>
                <input type="text" class="form-control" id="storeName" name="storeName">
            </div>
            <div class="mb-3">
                <label for="legalEntityName" class="form-label">Legal Entity Name</label>
                <input type="text" class="form-control" id="legalEntityName" name="legalEntityName">
            </div>
            <div class="mb-3">
                <label for="storeAddress" class="form-label">Store Address</label>
                <input type="text" class="form-control" id="storeAddress" name="storeAddress">
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save changes</button>
        </form>
      </div>
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
            <input type="hidden" id="reportStoreId">
            <input type="hidden" id="reportStoreId" name="storetId">
          <input type="hidden" id="reportStoreName" name="storeName">
            <div class="mb-3">
                <label for="reportType" class="form-label">Report Type</label>
                <select class="form-select" id="reportType" required>
                    <option value="" selected disabled>-- Select Report Type --</option>
                    <option value="Coupled">Coupled</option>
                    <option value="Decoupled">Decoupled</option>
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
            <button type="button" class="btn btn-primary" style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;" id="submitReport">Generate Report</button>
        </form>
      </div>
    </div>
  </div>
</div>
<div id="alertContainer"></div>
<script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
<script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
<script src="./js/script.js"></script>
<script>
$(document).ready(function() {
    if ($.fn.DataTable.isDataTable('#example')) {
        $('#example').DataTable().destroy();
    }
    
    $('#example').DataTable({
        scrollX: true,
        columnDefs: [
          { orderable: false, targets: [ 2, 3, 4] }    // Disable sorting for the first column
        ],
        order: []  // Ensure no initial ordering
    });
});

function editStore(storeId) {
    // Fetch the current data of the selected store
    var storeRow = $('#dynamicTableBody').find('tr[data-uuid="' + storeId + '"]');
    var storeName = storeRow.find('td:nth-child(2)').text();
    var legalEntityName = storeRow.find('td:nth-child(3)').text();
    var storeAddress = storeRow.find('td:nth-child(4)').text();
    var merchantId = "<?php echo htmlspecialchars($merchant_id); ?>"; // Set from PHP
    var merchantName = "<?php echo htmlspecialchars($merchant_name); ?>"; // Set from PHP

    // Set values in the edit modal
    $('#storeId').val(storeId);
    $('#storeName').val(storeName);
    $('#storeAddress').val(storeAddress);
    $('#legalEntityName').val(legalEntityName);
    $('#merchantId').val(merchantId);
    $('#merchantName').val(merchantName);

    // Open the edit modal
    $('#editStoreModal').modal('show');
}

function viewOrder(storeId, merchantName, storeName) {
    window.location.href = 'order/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
}

function viewReport(storeId, merchantName, storeName) {
    window.location.href = 'settlement_reports.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
}
</script>
<script>
function checkReport(storeId, storeName, storeName, legalEntityName, storeAddress) {
    $('#reportStoreId').val(storeId);
    $('#reportStoreName').val(storeName); 
    // Show the correct modal (checkReportModal)
    $('#checkReportModal').modal('show');
}

$('#submitReport').on('click', function () {
    var storeId = $('#reportStoreId').val();
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
        data: { store_id: storeId, start_date: startDate, end_date: endDate },
        success: function (response) {
            console.log(response);

            // Hide the modal first
            $('#checkReportModal').modal('hide'); // Correct modal ID

            var customAlert = $('<div class="alert-custom alert alert-success" role="alert" style="height:250px; display: flex; flex-direction: column; justify-content: center; align-items: center; padding-top:30px;">' +
                          '<span><i class="fa-solid fa-circle-check fa-xl" style="font-size:80px;"></i></span>' +
                          '<span><p style="padding-top:50px; font-size:15px;">Report generated successfully!</p></span>' +
                          '</div>');

      // Append the custom alert to a specific location, e.g., at the top of the page or a specific container
      $('#alertContainer').append(customAlert);

      var storeName = $('#dynamicTableBody').find('tr[data-uuid="' + storeId + '"]').find('td:nth-child(2)').text();
            
            // Redirect after a short delay
            setTimeout(function() {
                window.location.href = 'settlement_reports.php?store_id=' + storeId + '&store_name=' + encodeURIComponent(storeName);
            }, 3000); // Delay of 3 seconds before redirection
        },
        error: function (xhr, status, error) {
            console.error('Error:', error);
            $('#checkReportModal').modal('hide'); // Correct modal ID
        }
    });
});
</script>
</body>
</html>
