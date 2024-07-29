<?php
include_once("../../header.php");

$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

function displayStore($merchant_id, $merchant_name)
{
    global $conn, $type;

    $sql = "SELECT * FROM promo WHERE merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortPromoId = substr($row['promo_id'], 0, 8);
            $start_date = empty($row['start_date']) ? 'No Start Date' : $row['start_date'];
            $end_date = empty($row['end_date']) ? 'No End Date' : $row['end_date'];
            
            // Prepare truncated and full text for promo_details, remarks and remarks2
            $promo_details_full = $row['promo_details'];
            $promo_details = strlen($row['promo_details']) > 30 ? substr($row['promo_details'], 0, 30) . '...' : $row['promo_details'];
            $remarks_full = empty($row['remarks']) ? '-' : $row['remarks'];
            $remarks = empty($row['remarks']) ? '-' : (strlen($row['remarks']) > 30 ? substr($row['remarks'], 0, 30) . '...' : $row['remarks']);
            $remarks2_full = empty($row['remarks2']) ? '-' : $row['remarks2'];
            $remarks2 = empty($row['remarks2']) ? '-' : (strlen($row['remarks2']) > 30 ? substr($row['remarks2'], 0, 30) . '...' : $row['remarks2']);

            echo "<tr style='padding:15px 0;' data-id='" . $row['promo_id'] . "'>";
            echo "<td>" . $shortPromoId . "</td>";
            echo "<td>" . $row['promo_code'] . "</td>";
            echo "<td>" . $row['promo_amount'] . "</td>";
            echo "<td>" . $row['voucher_type'] . "</td>";
            echo "<td>" . $row['promo_category'] . "</td>";
            echo "<td>" . $row['promo_group'] . "</td>";
            echo "<td>" . $row['promo_type'] . "</td>";
            echo "<td class='text-cell' data-full='" . htmlentities($promo_details_full) . "' data-short='" . htmlentities($promo_details) . "'>" . $promo_details . "</td>";
            echo "<td class='text-cell' data-full='" . htmlentities($remarks_full) . "' data-short='" . htmlentities($remarks) . "'>" . $remarks . "</td>";
            echo "<td>" . $row['bill_status'] . "</td>";
            echo "<td>" . $start_date . "</td>";
            echo "<td>" . $end_date . "</td>";
            echo "<td class='text-cell' data-full='" . htmlentities($remarks2_full) . "' data-short='" . htmlentities($remarks2) . "'>" . $remarks2 . "</td>";
            echo "<td class='actions-cell'>";
            echo "<button class='btn action-btn' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#F1F1F1;'></i></button>";
            echo "<div class='mt-2 actions-list' style='display:none;cursor:pointer;'>"; // Hidden initially
            echo "<ul class='list-group'>";

            // Dropdown menu items
            if ($type !== 'User') {
                echo "<li class='list-group-item action-item'><a href='#' class='edit-link' data-promo-id='" . htmlentities($row['promo_id']) . "' data-promo-code='" . htmlentities($row['promo_code']) . "' data-promo-amount='" . htmlentities($row['promo_amount']) . "' data-voucher-type='" . htmlentities($row['voucher_type']) . "' data-promo-category='" . htmlentities($row['promo_category']) . "' data-promo-group='" . htmlentities($row['promo_group']) . "' data-promo-type='" . htmlentities($row['promo_type']) . "' data-promo-details='" . htmlentities($promo_details_full) . "' data-remarks='" . htmlentities($remarks_full) . "' data-bill-status='" . htmlentities($row['bill_status']) . "' data-start-date='" . htmlentities($start_date) . "' data-end-date='" . htmlentities($end_date) . "' data-remarks2='" . htmlentities($row['remarks2']) . "' style='color:#E96529;'>Edit</a></li>";
            }

            echo "<li class='list-group-item action-item' style='animation-delay: 0.2s;'><a href='#' onclick='viewHistory(\"" . htmlentities($merchant_id) . "\", \"" . htmlentities($merchant_name) . "\", \"" . htmlentities($row['promo_id']) . "\", \"" . htmlentities($row['promo_code']) . "\")' style='color:#E96529;'>View History</a></li>";

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
    <title><?php echo htmlspecialchars($merchant_name); ?> - Promos</title>
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
        <div class="row pb-2 title" aria-label="breadcrumb">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                                <li class="breadcrumb-item"><a href="../index.php"
                                        style="color:#E96529; font-size:14px;">Merchants</a></li>
                                <li class="breadcrumb-item dropdown">
                                    <a href="#" class="dropdown-toggle" role="button" id="storeDropdown"
                                        data-bs-toggle="dropdown" aria-expanded="false"
                                        style="color:#E96529;font-size:14px;">
                                        Promos
                                    </a>
                                    <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                        <li><a class="dropdown-item"
                                                href="../store/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Stores</a>
                                        </li>
                                        <li><a class="dropdown-item"
                                                href="index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers" style="color:#4BB0B8;">Promos</a>
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
                            <i class="fa-solid fa-plus"></i> Add Promo
                        </button>
                    </a>
                </div>

                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:200%;">
                        <thead>
                            <tr>
                                <th class="first-col">Promo ID</th>
                                <th>Promo Code</th>
                                <th>Promo Amount</th>
                                <th>Voucher Type</th>
                                <th>Promo Category</th>
                                <th>Promo Group</th>
                                <th>Promo Type</th>
                                <th>Promo Details</th>
                                <th>Remarks</th>
                                <th>Bill Status</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Remarks 2</th>
                                <th class="action-col" style="width:30px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayOffers($merchant_id, $merchant_name); ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal: Edit Promo Details -->
    <div class="modal fade" id="editStoreModal" data-bs-backdrop="static" tabindex="-1"
        aria-labelledby="editStoreModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content" style="border-radius:20px;">
                <div class="modal-header border-0">
                    <p class="modal-title" id="editPromoModalLabel">Edit Promo Details</p>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editPromoForm" action="edit.php" method="POST">
                        <input type="hidden" id="promoId" name="promoId">
                        <input type="hidden" id="merchantId" name="merchantId"
                            value="<?php echo htmlspecialchars($merchant_id); ?>">
                        <input type="hidden" id="merchantName" name="merchantName"
                            value="<?php echo htmlspecialchars($merchant_name); ?>">
                        <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="promoCode" class="form-label">
                                    Promo Code<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <input type="text" class="form-control" id="promoCode" name="promoCode" 
                                    placeholder="Enter promo code" required maxlength="100">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="promoDetails" class="form-label">
                                    Promo Details<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <textarea class="form-control" rows="1" id="promoDetails" name="promoDetails" 
                                    placeholder="Enter promo details" required></textarea>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="promoAmount" class="form-label">
                                    Promo Amount<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <input type="number" class="form-control" id="promoAmount" name="promoAmount" 
                                    placeholder="0" min="0" required>
                            </div>
                            <div class="col-md-6 mb-3"> 
                                <label for="remarks" class="form-label">Remarks</label>
                                <textarea class="form-control" rows="1" id="remarks" name="remarks" placeholder="Enter remarks" ></textarea>
                            </div>
                                                       
                            <div class="col-md-6 mb-3">
                                <label for="voucherType" class="form-label">
                                    Voucher Type<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <select class="form-select" id="voucherType" name="voucherType" required>
                                    <option value="Coupled">Coupled</option>
                                    <option value="Decoupled">Decoupled</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="billStatus" class="form-label">
                                    Bill Status<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <select class="form-select" id="billStatus" name="billStatus" required>
                                    <option selected disabled>-- Select Bill Status --</option>
                                    <option value="PRE-TRIAL">PRE-TRIAL</option>
                                    <option value="BILLABLE">BILLABLE</option>
                                    <option value="NOT BILLABLE">NOT BILLABLE</option>
                                </select>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="promoCategory" class="form-label">
                                    Promo Category<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <select class="form-select" id="promoCategory" name="promoCategory" required>
                                    <option selected disabled>-- Select Promo Category --</option>
                                    <option value="Grab & Go">Grab & Go</option>
                                    <option value="Casual Dining">Casual Dining</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="startDate" class="form-label">
                                    Start Date<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <input type="date" class="form-control" id="startDate" name="startDate" required>
                                <div class="form-check">
                                    <input type="checkbox" class="form-check-input" id="NoStartDate" name="NoStartDate" style="accent-color:#E96529;">
                                    <label class="form-check-label" for="NoStartDate">No Start Date</label>
                                </div>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="promoType" class="form-label">
                                    Promo Type<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <select class="form-select" id="promoType" name="promoType" required>
                                    <option selected disabled>-- Select Promo Type --</option>    
                                    <option value="BOGO">BOGO</option>
                                    <option value="Bundle">Bundle</option>
                                    <option value="Fixed discount">Fixed discount</option>
                                    <option value="Free item">Free item</option>
                                    <option value="Fixed discount, Free item">Fixed discount, Free item</option>
                                    <option value="Free item, Fixed discount">Free item, Fixed discount</option>
                                    <option value="Percent discount">Percent discount</option>
                                    <option value="X for Y">X for Y</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="endDate" class="form-label">
                                    End Date<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <input type="date" class="form-control" id="endDate" name="endDate" required>
                                <div class="form-check">
                                    <input type="checkbox" class="form-check-input" id="NoEndDate" name="NoEndDate" style="accent-color:#E96529 !important;">
                                    <label class="form-check-label" for="NoEndDate">No End Date</label>
                                </div>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="promoGroup" class="form-label">
                                    Promo Group<span class="text-danger" style="padding:2px">*</span>
                                </label>
                                <select class="form-select" id="promoGroup" name="promoGroup" required>
                                    <option selected disabled>-- Select Promo Group --</option>
                                    <option value="Booky">Booky</option>
                                    <option value="Gcash">Gcash</option>
                                    <option value="Unionbank">Unionbank</option>
                                    <option value="Gcash/Booky">Gcash/Booky</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="remarks2" class="form-label">Remarks 2</label>
                                <textarea class="form-control" rows="1" id="remarks2" name="remarks2" placeholder="Enter additional remarks" ></textarea>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary modal-save-btn">Save changes</button>
                    </form>
                </div>
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
                    { orderable: false, targets: [8, 12, 13] }    // Disable sorting for the first column
                ],
                order: [[1, 'asc']]
            });
        });

        function viewHistory(storeId, merchantName, promoId, promoCode) {
            window.location.href = 'history.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId) + '&promo_id=' + encodeURIComponent(promoId) + '&promo_code=' + encodeURIComponent(promoCode);
        }
    </script>

    <!-- Script: Edit Promo Details -->
    <script>
        function editPromo(promoId) {
            // Fetch the current data of the selected promo
            var promoRow = $('#dynamicTableBody').find('tr[data-id="' + promoId + '"]');
            var promoCode = promoRow.find('td:nth-child(2)').text();
            var promoAmount = promoRow.find('td:nth-child(3)').text();
            var voucherType = promoRow.find('td:nth-child(4)').text();
            var promoCategory = promoRow.find('td:nth-child(5)').text();
            var promoGroup = promoRow.find('td:nth-child(6)').text();
            var promoType = promoRow.find('td:nth-child(7)').text();
            var promoDetails = promoRow.find('td:nth-child(8)').text();
            var remarks = promoRow.find('td:nth-child(9)').text();
            var billStatus = promoRow.find('td:nth-child(10)').text();
            var startDate = promoRow.find('td:nth-child(11)').text();
            var endDate = promoRow.find('td:nth-child(12)').text();
            var remarks2 = promoRow.find('td:nth-child(13)').text();
            var merchantId = "<?php echo htmlspecialchars($merchant_id); ?>"; // Set from PHP
            var merchantName = "<?php echo htmlspecialchars($merchant_name); ?>"; // Set from PHP

            $('#promoId').val(promoId);
            $('#promoCode').val(promoCode);
            $('#promoDetails').val(promoDetails);
            $('#promoAmount').val(promoAmount);

            if (remarks === '-') {
                $('#remarks').val(null);
            } else {
                $('#remarks').val(remarks);
            }

            $('#voucherType').val(voucherType);
            $('#billStatus').val(billStatus);
            $('#promoCategory').val(promoCategory);
            $('#promoGroup').val(promoGroup);
            $('#promoType').val(promoType);
            $('#startDate').val(startDate);
            $('#endDate').val(endDate);

            if (remarks2 === '-') {
                $('#remarks2').val(null);
            } else {
                $('#remarks2').val(remarks2);
            }

            // Open the edit modal
            $('#editStoreModal').modal('show');
        }

    </script>
   <script>
document.addEventListener('DOMContentLoaded', function() {
    // Ensure actions toggle function works with dynamic content
    document.body.addEventListener('click', function(event) {
        if (event.target.closest('.btn') && event.target.closest('.actions-cell')) {
            var button = event.target.closest('.btn');
            var actionsList = button.nextElementSibling;

            if (actionsList.style.display === 'none' || actionsList.style.display === '') {
                actionsList.style.display = 'block';
            } else {
                actionsList.style.display = 'none';
            }
        }
    });
});
</script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Event delegation for edit link
    document.body.addEventListener('click', function(event) {
        if (event.target.classList.contains('edit-link')) {
            event.preventDefault();
            var promoId = event.target.getAttribute('data-promo-id');
            var promoCode = event.target.getAttribute('data-promo-code');
            var merchantName = event.target.getAttribute('data-merchant-name');
            var promoAmount = event.target.getAttribute('data-promo-amount');
            var voucherType = event.target.getAttribute('data-voucher-type');
            var promoCategory = event.target.getAttribute('data-promo-category');
            var promoGroup = event.target.getAttribute('data-promo-group');
            var promoType = event.target.getAttribute('data-promo-type');
            var promoDetails = event.target.getAttribute('data-promo-details');
            var remarks = event.target.getAttribute('data-remarks');
            var billStatus = event.target.getAttribute('data-bill-status');
            var startDate = event.target.getAttribute('data-start-date');
            var endDate = event.target.getAttribute('data-end-date');
            var remarks2 = event.target.getAttribute('data-remarks2');
            var noStartDateChecked = event.target.getAttribute('data-nostartdate');

            // Set the modal input fields with the current data
            $('#promoId').val(promoId);
            $('#editPromoForm #promoCode').val(promoCode);
            $('#editPromoForm #merchantName').val(merchantName);
            $('#editPromoForm #promoAmount').val(promoAmount);
            $('#editPromoForm #voucherType').val(voucherType);
            $('#editPromoForm #promoCategory').val(promoCategory);
            $('#editPromoForm #promoGroup').val(promoGroup);
            $('#editPromoForm #promoType').val(promoType);
            $('#editPromoForm #promoDetails').val(promoDetails);
            $('#editPromoForm #remarks').val(remarks);
            $('#editPromoForm #billStatus').val(billStatus);
            $('#editPromoForm #startDate').val(startDate);
            $('#editPromoForm #endDate').val(endDate);
            $('#editPromoForm #remarks2').val(remarks2);

            // Set the NoStartDate checkbox
            $('#editPromoForm #NoStartDate').prop('checked', noStartDateChecked === 'checked');

            // Show the modal
            $('#editStoreModal').modal('show');
        }
    });

    // Event delegation for text toggle
    document.body.addEventListener('click', function(event) {
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
});

  </script>
<script>
    function updateDateFields() {
        // Get the date fields
        var startDate = document.getElementById('startDate');
        var endDate = document.getElementById('endDate');
        
        // Get the checkboxes
        var noStartDateCheckbox = document.getElementById('NoStartDate');
        var noEndDateCheckbox = document.getElementById('NoEndDate');

        // Update the checkbox based on the date field values
        noStartDateCheckbox.checked = !startDate.value;
        noEndDateCheckbox.checked = !endDate.value;

        // Disable or enable the date fields based on the checkbox states
        startDate.disabled = noStartDateCheckbox.checked;
        endDate.disabled = noEndDateCheckbox.checked;
    }

    document.getElementById('editStoreModal').addEventListener('shown.bs.modal', function () {
        updateDateFields();
    });

    // Add event listeners to checkboxes to handle their state changes
    document.getElementById('NoStartDate').addEventListener('change', function() {
        var startDate = document.getElementById('startDate');
        startDate.disabled = this.checked;
        if (this.checked) {
            startDate.value = '';
        }
    });

    document.getElementById('NoEndDate').addEventListener('change', function() {
        var endDate = document.getElementById('endDate');
        endDate.disabled = this.checked;
        if (this.checked) {
            endDate.value = '';
        }
    });

    // Add event listeners to date fields to automatically check the checkboxes if the date fields are cleared
    document.getElementById('startDate').addEventListener('input', function () {
        if (!this.value) {
            document.getElementById('NoStartDate').checked = true;
            this.disabled = true;
        } else {
            document.getElementById('NoStartDate').checked = false;
            this.disabled = false;
        }
    });

    document.getElementById('endDate').addEventListener('input', function () {
        if (!this.value) {
            document.getElementById('NoEndDate').checked = true;
            this.disabled = true;
        } else {
            document.getElementById('NoEndDate').checked = false;
            this.disabled = false;
        }
    });
</script>
</body>

</html>
