<?php
include_once ("../../header.php");

$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

function displayStore($merchant_id)
{
    global $conn, $type;

    $sql = "SELECT * FROM store_view WHERE merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortStoreId = substr($row['store_id'], 0, 8);
            $store_address = empty($row['store_address']) ? '-' : $row['store_address'];

            // Prepare truncated and full text for email_address
            $email_address_full = empty($row['email_address']) ? '-' : $row['email_address'];
            $email_address = strlen($row['email_address']) > 30 ? substr($row['email_address'], 0, 30) . '...' : $row['email_address'];

            echo "<tr style='padding:15px 0;' data-uuid='" . $row['store_id'] . "'>";
            echo "<td>" . $shortStoreId . "</td>";
            echo "<td>" . $row['store_name'] . "</td>";
            echo "<td>" . $row['legal_entity_name'] . "</td>";
            echo "<td>" . $store_address . "</td>";
            echo "<td style='display:none;'>" . htmlspecialchars($email_address_full) . "</td>";
            echo "<td class='text-cell' data-full='" . htmlentities($email_address_full) . "' data-short='" . htmlentities($email_address) . "'>" . $email_address . "</td>";
            echo "<td class='actions-cell'>";
            echo "<button class='btn action-btn' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#F1F1F1;'></i></button>";
            echo "<div class='mt-2 actions-list' style='display:none;cursor:pointer;'>"; // Hidden initially
            echo "<ul class='list-group'>";

            $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
            $escapedStoreName = htmlspecialchars($row['store_name'], ENT_QUOTES, 'UTF-8');
            $escapedLegalEntityName = htmlspecialchars($row['legal_entity_name'], ENT_QUOTES, 'UTF-8');
            $escapedStoreAddress = empty($row['store_address']) ? '-' : htmlspecialchars($row['store_address'], ENT_QUOTES, 'UTF-8');


            if ($type !== 'User') {
                echo "<li class='list-group-item action-item'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;pointer'>View</a></li>";
                echo "<li class='list-group-item action-item'><a href='#' onclick='editStore(\"" . $row['store_id'] . "\")' style='color:#E96529;'>Edit</a></li>";
            } else {
                echo "<li class='list-group-item action-item'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View</a></li>";
            }

            echo "<li class='list-group-item action-item'><a href='#' onclick='checkReport(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\", \"" . $escapedLegalEntityName . "\", \"" . $escapedStoreAddress . "\")' style='color:#E96529;'>Check Report</a></li>";
            echo "<li class='list-group-item action-item'><a href='#' onclick='viewReport(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $escapedStoreName . "\", \"" . $escapedLegalEntityName . "\")' style='color:#E96529;'>View Report</a></li>";

            echo "</ul>";
            echo "</div>";

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
    <title><?php echo htmlspecialchars($merchant_name); ?> - Stores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="../../style.css">
    <style>
        body {
            background-image: url("../../images/bg_booky.png"); 
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
                font-weight: 400;
                padding-left: 50% !important;
            }

            td:before {
                position: absolute;
                top: 6px;
                left: 6px;
                width: auto;
                padding-right: 10px;
                white-space: nowrap;
                font-weight: bold;
                text-align: left !important;
            }

            td:nth-of-type(1):before {
                content: "Store ID";
            }

            td:nth-of-type(2):before {
                content: "Store Name";
            }

            td:nth-of-type(3):before {
                content: "Legal Entity Name";
            }

            td:nth-of-type(4):before {
                content: "Store Address";
            }

            td:nth-of-type(6):before {
                content: "Email Address";
            }

            td:nth-of-type(7):before {
                content: "Actions";
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
  color:#E96529;
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
  0%, 20%, 80%, 100% {
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
   <div class="lds-default"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>
  </div>
  Loading, Please wait...
</div>
    <div class="cont-box">
        <div class="custom-box pt-4">
            <div class="sub" style="text-align:left;">
                <div class="voucher-type">
                    <div class="row pb-2 title" aria-label="breadcrumb">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                                <li class="breadcrumb-item">
                                    <a href="../index.php" style="color:#E96529; font-size:14px;">
                                        Merchants
                                    </a>
                                </li>
                                <li class="breadcrumb-item dropdown">
                                    <a href="#" class="dropdown-toggle" role="button" id="storeDropdown"
                                        data-bs-toggle="dropdown" aria-expanded="false"
                                        style="color:#E96529;font-size:14px;">
                                        Stores
                                    </a>
                                    <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                        <li><a class="dropdown-item"
                                                href="index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers" style="color:#4BB0B8;"> Stores</a>
                                        </li>
                                        <li><a class="dropdown-item"
                                                href="../promo/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Promos</a>
                                        </li>
                                    </ul>
                                </li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <div class="add-btns">
                    <p class="title2"><?php echo htmlspecialchars($merchant_name); ?></p>
                    <a href="upload.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>">
                        <button type="button" class="btn btn-primary add-merchant">
                            <i class="fa-solid fa-plus"></i> Add Store
                        </button>
                    </a>
                </div>
                
                <div class="content">
                    <table id="example" class="table bord" style="width:100%;">
                        <thead>
                            <tr>
                                <th class="first-col">Store ID</th>
                                <th>Store Name</th>
                                <th>Legal Entity Name</th>
                                <th>Store Address</th>
                                <th style="display:none;"></th>
                                <th>Email Address</th>
                                <th class="action-col" style="width:10%;">Actions</th>
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

    <!-- Modal: Edit Store Details -->
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
                        <input type="hidden" id="merchantId" name="merchantId"
                            value="<?php echo htmlspecialchars($merchant_id); ?>">
                        <input type="hidden" id="merchantName" name="merchantName"
                            value="<?php echo htmlspecialchars($merchant_name); ?>">
                        <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">

                        <div class="mb-3">
                            <label for="storeName" class="form-label">
                                Store Name<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input type="text" class="form-control" id="storeName" name="storeName"
                                placeholder="Enter store name" required maxlength="255">
                        </div>
                        <div class="mb-3">
                            <label for="legalEntityName" class="form-label">Legal Entity Name</label>
                            <input type="text" class="form-control" id="legalEntityName" name="legalEntityName"
                                placeholder="Enter legal entity name" maxlength="255">
                        </div>
                        <div class="mb-3">
                            <label for="storeAddress" class="form-label">Store Address</label>
                            <textarea class="form-control" rows="2" id="storeAddress" name="storeAddress"
                                placeholder="Enter store address"></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="emailAddress" class="form-label">Email Address</label>
                            <textarea class="form-control" rows="2" id="emailAddress" name="emailAddress"
                                placeholder="Enter email address"></textarea>
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
                        <input type="hidden" id="reportStoreId" name="storeId">
                        <input type="hidden" id="reportStoreName" name="storeName">
                        <input type="hidden" id="merchantId" name="merchantId" value="<?php echo htmlspecialchars($merchant_id); ?>">
                        <input type="hidden" id="merchantName" name="merchantName" value="<?php echo htmlspecialchars($merchant_name); ?>">
                        <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">

                        <div class="mb-3">
                            <label for="reportType" class="form-label">
                                Report Type<span class="text-danger" style="padding:2px">*</span>                                
                            </label>
                            <select class="form-select" id="reportType" required>
                                <option selected disabled>-- Select Report Type --</option>
                                <option value="Coupled">Coupled</option>
                                <option value="Decoupled">Decoupled</option>
                                <option value="GCash">GCash</option>
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
    <script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
    <script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
    <script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
    <script src="./js/script.js"></script>
    
    <!-- Script: DataTable -->
    <script>
        $(window).on('load', function() {
   $('.loading').hide();
   $('.cont-box').show();

   var table = $('#example').DataTable({
      scrollX: true,
      columnDefs: [
            { orderable: false, targets: [4, 5, 6] }
          ],
      order: [[1, 'asc']]
   }); 
  });
    </script>        

    <!-- Script: Edit Store Details -->
    <script>    
        function editStore(storeId) {
            var storeRow = $('#dynamicTableBody').find('tr[data-uuid="' + storeId + '"]');
            var storeName = storeRow.find('td:nth-child(2)').text();
            var legalEntityName = storeRow.find('td:nth-child(3)').text();
            var storeAddress = storeRow.find('td:nth-child(4)').text();
            var emailAddress = storeRow.find('td:nth-child(5)').text();
            var merchantId = "<?php echo htmlspecialchars($merchant_id); ?>";
            var merchantName = "<?php echo htmlspecialchars($merchant_name); ?>"; // Set from PHP

            // Set values in the edit modal
            $('#storeId').val(storeId);
            $('#storeName').val(storeName);
            
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
            
            $('#merchantId').val(merchantId);
            $('#merchantName').val(merchantName);

            // Open the edit modal
            $('#editStoreModal').modal('show');
        }

        function viewOrder(storeId, merchantName, storeName) {
            window.location.href = 'order/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
        }

        function viewReport(storeId, merchantName, storeName) {
            window.location.href = 'reports/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
        }
    </script>

    <!-- Script: Check Report -->
    <script>
        function checkReport(storeId, storetName) {
            // Set the merchantId and merchantName in the report modal
            document.getElementById('reportStoreId').value = storeId;
            document.getElementById('reportStoreName').value = storeName;

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
            } else if (reportType === 'GCash') {
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