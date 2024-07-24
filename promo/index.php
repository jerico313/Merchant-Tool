<?php
include_once("../header.php");

function displayStore()
{
    global $conn, $type;

    $sql = "SELECT promo.*, merchant.merchant_name 
            FROM promo 
            JOIN merchant ON promo.merchant_id = merchant.merchant_id";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortPromoId = substr($row['promo_id'], 0, 8);
            $promo_amount = number_format($row['promo_amount'], 2);
            $start_date = empty($row['start_date']) ? 'No Start Date' : $row['start_date'];
            $end_date = empty($row['end_date']) ? 'No End Date' : $row['end_date'];

            
            echo "<tr style='padding:15px 0;' data-uuid='" . $row['promo_id'] . "'>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $shortPromoId . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['merchant_name'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['promo_code'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $promo_amount . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['voucher_type'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['promo_category'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['promo_group'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['promo_type'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['promo_details'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['remarks'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['bill_status'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $start_date . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $end_date . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['remarks2'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;' class='actions-cell'>";
            echo "<button class='btn' style='border:solid #4BB0B8 2px;background-color:#4BB0B8;border-radius:20px;padding:0 10px;box-shadow: 0px 2px 5px 0px rgba(0,0,0,0.27)inset !important;-webkit-box-shadow: 0px 2px 5px 0px rgba(0,0,0,0.27)inset !important;-moz-box-shadow: 0px 2px 5px 0px rgba(0,0,0,0.27)inset !important;' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#F1F1F1;'></i></button>";
            echo "<div class='mt-2 actions-list' style='display:none;cursor:pointer;'>"; // Hidden initially
            echo "<ul class='list-group'>";

            // Dropdown menu items
            if ($type !== 'User') {
                echo "<li class='list-group-item action-item' style='animation-delay: 0.1s;'><a href='#' onclick='editPromo(\"" . $row['promo_id'] . "\", \"" . $row['promo_id'] . "\", \"" . $row['promo_code'] . "\")' style='color:#E96529;pointer'>Edit</a></li>";
            }

            echo "<li class='list-group-item action-item' style='animation-delay: 0.2s;'><a href='#' onclick='viewHistory(\"" . $row['promo_id'] . "\", \"" . $row['promo_id'] . "\", \"" . $row['promo_code'] . "\")' style='color:#E96529;pointer'>View History</a></li>";

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
  <title>Promos</title>
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
      font-weight: 900;
      margin-right: auto;
      padding-left: 5vh;
      color: #E96529;
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
          <p class="title">Promos</p>
          <a href="upload.php"><button type="button" class="btn btn-danger add-merchant"><i
                class="fa-solid fa-upload"></i> Upload Promos</button></a>
        </div>

        <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
          <table id="example" class="table bord" style="width:200%;">
            <thead>
            <tr>
                  <th style="padding:10px;border-top-left-radius:10px;border-bottom-left-radius:10px;">Promo ID</th>
                  <th style="padding:10px;">Merchant Name</th>
                  <th style="padding:10px;">Promo Code</th>
                  <th style="padding:10px;">Promo Amount</th>
                  <th style="padding:10px;">Voucher Type</th>
                  <th style="padding:10px;">Promo Category</th>
                  <th style="padding:10px;">Promo Group</th>
                  <th style="padding:10px;">Promo Type</th>
                  <th style="padding:10px;">Promo Details</th>
                  <th style="padding:10px;">Remarks</th>
                  <th style="padding:10px;">Bill Status</th>
                  <th style="padding:10px;">Start Date</th>
                  <th style="padding:10px;">End Date</th>
                  <th style="padding:10px;">Remarks 2</th>
                  <th style='width:50px;padding:10px;border-top-right-radius:10px;border-bottom-right-radius:10px;'>Action</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayStore(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Edit Modal -->
    <div class="modal fade" id="editStoreModal" data-bs-backdrop="static" tabindex="-1"
        aria-labelledby="editStoreModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content" style="border-radius:20px;">
                <div class="modal-header border-0">
                    <p class="modal-title" id="editPromoModalLabel" style="font-size:15px;font-weight:bold;">Edit Promo
                        Details</p>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editPromoForm" action="edit.php" method="POST">
                        <input type="hidden" id="promoId" name="promoId">
                        <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="promoCode" class="form-label">Promo Code</label>
                                <input type="text" class="form-control" id="promoCode" name="promoCode">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="promoDetails" class="form-label">Promo Details</label>
                                <textarea class="form-control" rows="2" id="promoDetails" name="promoDetails"
                                    style="padding:5px 5px;" required></textarea>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="promoAmount" class="form-label">Promo Amount</label>
                                <input type="text" class="form-control" id="promoAmount" name="promoAmount">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="remarks" class="form-label">Remarks</label>
                                <input type="text" class="form-control" id="remarks" name="remarks">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="voucherType" class="form-label">Voucher Type</label>
                                <select class="form-select" id="voucherType"  name="voucherType" required>
                                    <option value="Coupled">Coupled</option>
                                    <option value="Decoupled">Decoupled</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="billStatus" class="form-label">Bill Status</label>
                                <select class="form-select" id="billStatus" name="billStatus" required>
                                    <option value="PRE-TRIAL">PRE-TRIAL</option>
                                    <option value="BILLABLE">BILLABLE</option>
                                    <option value="NOT BILLABLE">NOT BILLABLE</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="promoCategory" class="form-label">Promo Category</label>
                                <select class="form-select" id="promoCategory" name="promoCategory" required>
                                    <option value="Grab & Go">Grab & Go</option>
                                    <option value="Casual Dining">Casual Dining</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="promoGroup" class="form-label">Promo Group</label>
                                <select class="form-select" id="promoGroup" name="promoGroup" required>
                                    <option value="Booky">Booky</option>
                                    <option value="Gcash">Gcash</option>
                                    <option value="Unionbank">Unionbank</option>
                                    <option value="Gcash/Booky">Gcash/Booky</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="promoType" class="form-label">Promo Type</label>
                                <select class="form-select" id="promoType" name="promoType" required>
                                    <option value="BOGO">BOGO</option>
                                    <option value="Bundle">Bundle</option>
                                    <option value="Fixed discount">Fixed discount</option>
                                    <option value="Free item">Free item</option>
                                    <option value="Fixed discount, Free item">Fixed discount, Free item</option>
                                    <option value="Percent discount">Percent discount</option>
                                    <option value="X for Y">X for Y</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <div class="mb-3">
                                    <label for="startDate" class="form-label">Start Date</label>
                                    <input type="date" class="form-control" id="startDate" name="startDate" required>
                                </div>
                                <div class="">
                                    <label for="endDate" class="form-label">End Date</label>
                                    <input type="date" class="form-control" id="endDate" name="endDate" required>
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary"
                            style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save
                            changes</button>
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
            { orderable: false, targets: [3, 4, 5, 6, 7, 8, 9, 10, 11] }    // Disable sorting for the specified columns
          ],
          order: [[1, 'asc'],[2, 'asc']]  // Ensure no initial ordering
        });
      });

        
        function viewHistory(storeId, promoId, promoCode) {
            window.location.href = 'history.php?store_id=' + encodeURIComponent(storeId) + '&promo_id=' + encodeURIComponent(promoId) + '&promo_code=' + encodeURIComponent(promoCode);
        }
    </script>
    <script>
        function editPromo(promoId) {
            // Fetch the current data of the selected promo
            var promoRow = $('#dynamicTableBody').find('tr[data-uuid="' + promoId + '"]');
            var merchantName = promoRow.find('td:nth-child(2)').text();
            var promoCode = promoRow.find('td:nth-child(3)').text();
            var promoAmount = promoRow.find('td:nth-child(4)').text();
            var voucherType = promoRow.find('td:nth-child(5)').text();
            var promoCategory = promoRow.find('td:nth-child(6)').text();
            var promoGroup = promoRow.find('td:nth-child(7)').text();
            var promoType = promoRow.find('td:nth-child(8)').text();
            var promoDetails = promoRow.find('td:nth-child(9)').text();
            var remarks = promoRow.find('td:nth-child(10)').text();
            var billStatus = promoRow.find('td:nth-child(11)').text();
            var startDate = promoRow.find('td:nth-child(12)').text();
            var endDate = promoRow.find('td:nth-child(13)').text();
            var remarks2 = promoRow.find('td:nth-child(14)').text();

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

            // Show the modal
            $('#editStoreModal').modal('show');
        }
    </script>
    <script>
    function toggleActions(button) {
        // Find the actions-list div relative to the button
        var actionsList = button.nextElementSibling;

        // Toggle the display style of the actions-list div
        if (actionsList.style.display === 'none' || actionsList.style.display === '') {
            actionsList.style.display = 'block';
        } else {
            actionsList.style.display = 'none';
        }
    }
</script>
</body>

</html>
