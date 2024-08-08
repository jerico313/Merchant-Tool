<?php
include_once ("../header.php");

function displayOrder($store_id = null, $startDate = null, $endDate = null, $voucherType = null, $promoGroup = null, $billStatus = null, $type = 'User')
{
  include ("../inc/config.php");

  // Base SQL query
  $sql = "SELECT * FROM transaction_summary_view";
  $params = array();

  // Append voucher type filter if specified
  if ($voucherType) {
    $sql .= " AND `Voucher Type` = ?";
    $params[] = $voucherType;
  }

  if ($promoGroup) {
    $sql .= " AND `Promo Group` = ?";
    $params[] = $promoGroup;
  }

  if ($billStatus) {
    $sql .= " AND `Bill Status` = ?";
    $params[] = $billStatus;
  }

  // Append date range filter if both startDate and endDate are provided
  if ($startDate && $endDate) {
    $sql .= " AND `Transaction Date` BETWEEN ? AND ?";
    $params[] = $startDate;
    $params[] = $endDate;
  }

  // Prepare and execute the SQL query
  $stmt = $conn->prepare($sql);

  // Check if there are parameters to bind
  if (count($params) > 0) {
    $types = str_repeat("s", count($params)); // Adjust types if needed
    $stmt->bind_param($types, ...$params);
  }

  $stmt->execute();
  $result = $stmt->get_result();

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      echo "<tr style='padding:20px 0;' data-id='" . $row['Transaction ID'] . "'>";
      echo "<td style='width:2%;' id='transaction'><input style='accent-color:#E96529;' class='transaction' type='checkbox' name='transaction_ids[]' value='" . $row['Transaction ID'] . "'></td>";
      echo "<td style='width:4%;'>" . $row['Transaction ID'] . "</td>";
      echo "<td>" . $row['Store Name'] . "</td>";
      echo "<td>" . $row['Formatted Transaction Date'] . "</td>";
      echo "<td>" . $row['Customer ID'] . "</td>";
      echo "<td>" . $row['Customer Name'] . "</td>";
      echo "<td>" . $row['Promo Code'] . "</td>";
      echo "<td>" . $row['Voucher Type'] . "</td>";
      echo "<td>" . $row['Promo Category'] . "</td>";
      echo "<td>" . $row['Promo Group'] . "</td>";
      echo "<td>" . $row['Promo Type'] . "</td>";
      echo "<td>" . $row['Gross Amount'] . "</td>";
      echo "<td>" . $row['Discount'] . "</td>";
      echo "<td>" . $row['Cart Amount'] . "</td>";
      echo "<td>" . $row['Mode of Payment'] . "</td>";
      echo "<td>" . $row['Bill Status'] . "</td>";
      echo "<td>" . $row['Commission Type'] . "</td>";
      echo "<td>" . $row['Commission Rate'] . "</td>";
      echo "<td>" . $row['Commission Amount'] . "</td>";
      echo "<td>" . $row['Total Billing'] . "</td>";
      echo "<td>" . $row['PG Fee Rate'] . "</td>";
      echo "<td>" . $row['PG Fee Amount'] . "</td>";
      echo "<td style='display:none;'>" . $row['Transaction Date'] . "</td>";
      echo "<td>" . $row['Amount to be Disbursed'] . "</td>";
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
  <title>Transactions</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <link rel='stylesheet' href='https://cdn.datatables.net/fixedcolumns/3.3.3/css/fixedColumns.bootstrap5.min.css'>
  <script src='https://cdn.datatables.net/fixedcolumns/3.3.3/js/dataTables.fixedColumns.min.js'></script>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link rel="stylesheet" href="../style.css">
  <style>
    body {
      background-image: url("../images/bg_booky.png");
    }

    .second-col {
      <?php if ($type === 'User')
        echo 'padding: 10px;border-top-left-radius: 10px;border-bottom-left-radius: 10px;'; ?>
    }

    #select,
    #transaction {
      <?php if ($type === 'User')
        echo 'display:none;'; ?>
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
        padding-bottom: 10px;
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

    .delete {
      display: none;
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
          <p class="title">Transactions</p>
          <div class="dropdown">
            <button class="btn btn-primary dropdown-toggle check-report" type="button" id="dropdownMenuButton"
              data-bs-toggle="dropdown" aria-expanded="false"
              style="width:150px;margin-left:10px;border-radius:20px;height:32px;background-color: #4BB0B8;border:solid #4BB0B8 2px;">
              <i class="fa-solid fa-filter"></i> Filters
            </button>
            <div class="dropdown-menu dropdown-menu-center p-4" style="width:155px !important;"
              aria-labelledby="dropdownMenuButton">
              <form>
                <button type="button" class="btn all mt-2" id="btnShowAll">All</button>
                <button type="button" class="btn coupled mt-2" id="btnPretrial">PRE-TRIAL</button>
                <button type="button" class="btn decoupled mt-2" id="btnBillable">BILLABLE</button>
                <button type="button" class="btn decoupled mt-2" id="btnNotBillable">NOT BILLABLE</button>
              </form>
            </div>
          </div>
          <div class="dropdown">
            <button class="dropdown-toggle dateRange" type="button" id="dropdownMenuButton" data-bs-toggle="dropdown"
              aria-expanded="false"><i class="fa-solid fa-calendar"></i> Select Date Range</button>
            <div class="dropdown-menu p-4" aria-labelledby="dropdownMenuButton">
              <form id="dateFilterForm">
                <div class="form-group">
                  <label for="startDate">Start Date</label>
                  <input type="date" class="form-control" id="startDate" placeholder="Select start date" required>
                </div>

                <div class="form-group mt-3">
                  <label for="endDate">End Date</label>
                  <input type="date" class="form-control" id="endDate" placeholder="Select end date" required>
                </div>
                <button type="button" class="btn btn-warning mt-2" id="search"><i
                    class="fa-solid fa-magnifying-glass"></i> Search</button>
              </form>
            </div>
          </div>
          <a href="upload.php"><button type="button" class="btn btn-primary check-report"
              style="margin-left:10px; width:170px;"><i class="fa-solid fa-upload"></i> Upload Transactions</button></a>
          <button type="button" class="btn btn-danger delete" id="clearButton" style="margin-left:10px;"><i
              class="fa-solid fa-trash"></i> Delete</button>
        </div>
        <div class="content">
          <div class="table-container">
            <table id="example" class="table bord" style="width:320%;">
              <thead>
                <tr>
                  <th class="first-col" id="select" style="width:2%"></th>
                  <th class="second-col">Transaction ID</th>
                  <th>Store Name</th>
                  <th>Transaction Date</th>
                  <th>Customer ID</th>
                  <th>Customer Name</th>
                  <th>Promo Code</th>
                  <th>Voucher Type</th>
                  <th>Promo Category</th>
                  <th>Promo Group</th>
                  <th>Promo Type</th>
                  <th>Gross Amount</th>
                  <th>Discount</th>
                  <th>Cart Amount</th>
                  <th>Mode of Payment</th>
                  <th>Bill Status</th>
                  <th>Commission Type</th>
                  <th>Commission Rate</th>
                  <th>Commission Amount</th>
                  <th>Total Billing</th>
                  <th>PG Fee Rate</th>
                  <th>PG Fee Amount</th>
                  <th style="display:none;"></th>
                  <th class="action-col">Amount to be Disbursed</th>
                </tr>
              </thead>
              <tbody id="dynamicTableBody">
                <?php displayOrder(); ?>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- First Modal: Display selected transaction count -->
  <div class="modal fade" id="deleteCountModal" tabindex="-1" aria-labelledby="deleteCountModalLabel"
    aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
      <div class="modal-content" style="border-radius:20px;">
        <div class="modal-header border-0 text-center p-0">

        </div>
        <div class="modal-body" style="text-align:center;">
          <p class="modal-title" style="text-align:center;color:#cc001b;" id="deleteCountModalLabel">Delete Transaction
          </p><br>
          You have selected <span id="selectedCount"></span> transaction(s) for deletion. Are you sure you want to
          continue?
        </div>
        <div class="modal-footer border-0">
          <button type="button" class="btn btn-primary" id="proceedToDeleteButton"
            style="background-color:#cc001b;border:solid #cc001b 2px;width:100%;border-radius:20px;font-weight:bold;">Proceed</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"
            style="width:100%;border-radius:20px;background-color:#fff;color:#cc001b;border:solid #cc001b 2px;font-weight:bold;">Cancel</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Second Modal: Confirm deletion -->
  <div class="modal fade" id="deleteConfirmationModal" tabindex="-1" aria-labelledby="deleteConfirmationModalLabel"
    aria-hidden="true">
    <div class="modal-dialog modal-dialog-top modal-sm">
      <div class="modal-content" style="border-radius:20px;">
        <div class="modal-header border-0 text-center p-0">
        </div>

        <div class="modal-body" style="text-align:center;">
          <p class="modal-title" style="text-align:center;color:#cc001b;" id="deleteCountModalLabel">Delete Transaction</p>
          <br>
          <p>Are you sure you want to delete the selected transaction(s)?</p>
        </div>

        <div class="modal-footer border-0">
          <div class="row w-100">
            <div class="col-md-6 d-flex justify-content-start">
              <button type="button" class="btn btn-secondary w-100" data-bs-dismiss="modal"
                style="border-radius:20px;background-color:#fff;color:#cc001b;border:solid #cc001b 2px;font-weight:bold;">Cancel</button>
            </div>
            <div class="col-md-6 d-flex justify-content-end">
              <button type="button" class="btn btn-danger w-100" id="confirmDeleteButton"
                style="background-color:#cc001b;border:solid #cc001b 2px;border-radius:20px;font-weight:bold;">Delete</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>


  <script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
  <script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
  <script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
  <script src="./js/script.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"
    integrity="sha384-oBqDVmMz4fnFO9gybBogGzOgPHoK1O5jHbGc7F8yy3U9gknFyy7+X2AiOk7PM53i" crossorigin="anonymous">
    </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"
    integrity="sha384-oBqDVmMz4fnFO9gybBogGzOgPHoK1O5jHbGc7F8yy3U9gknFyy7+X2AiOk7PM53i" crossorigin="anonymous">
    </script>

  <script>
    $(window).on('load', function () {
      $('.loading').hide();
      $('.cont-box').show();

      var table = $('#example').DataTable({
        scrollX: true,
        columnDefs: [
          { orderable: false, targets: [0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 23] }
        ]
      });


      $('input[type="checkbox"]').change(function () {
        if ($('input[type="checkbox"]:checked').length > 0) {
          $('.delete').show();
        } else {
          $('.delete').hide();
        }
      });

      $.fn.dataTable.ext.search.push(
        function (settings, data, dataIndex) {
          var startDate = $('#startDate').val();
          var endDate = $('#endDate').val();
          var date = data[6].split(' ')[0]; // Only compare the date part

          if (startDate && endDate) {
            var endDatePlusOne = new Date(endDate);
            endDatePlusOne.setDate(endDatePlusOne.getDate() + 1);
            endDatePlusOne = endDatePlusOne.toISOString().split('T')[0]; // Convert back to string in YYYY-MM-DD format

            return (date >= startDate && date < endDatePlusOne);
          }
          return true; // If no date range is selected, return all rows
        }
      );

      // Search button click event
      $('#search').on('click', function () {
        table.draw();
      });

      // Voucher Type filter buttons click events
      $('#btnCoupled').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(7).search('^Coupled$', true, false).draw();
      });

      $('#btnDecoupled').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(7).search('^Decoupled$', true, false).draw();
      });

      $('#btnGCash').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(9).search('^Gcash$', true, false).draw();
      });

      $('#btnPretrial').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(15).search('PRE-TRIAL', true, false).draw();
      });

      $('#btnBillable').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(15).search('^BILLABLE$', true, false).draw();
      });

      $('#btnNotBillable').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(15).search('^NOT BILLABLE$', true, false).draw();
      });

      // Show All button click event
      $('#btnShowAll').on('click', function () {
        $('#startDate, #endDate').val('');
        table.search('').columns().search('').draw();
      });

      // Delete button click event
      $('#clearButton').on('click', function () {
        var selectedIds = [];
        $('input[name="transaction_ids[]"]:checked').each(function () {
          selectedIds.push($(this).val());
        });

        if (selectedIds.length > 0) {
          $('#selectedCount').text(selectedIds.length);
          $('#deleteCountModal').modal('show');
        } else {
          alert('No transactions selected for deletion.');
        }
      });

      // Proceed to delete button click event
      $('#proceedToDeleteButton').on('click', function () {
        $('#deleteCountModal').modal('hide');
        $('#deleteConfirmationModal').modal('show');
      });

      // Confirm delete button click event
      $('#confirmDeleteButton').on('click', function () {
        var selectedIds = [];
        $('input[name="transaction_ids[]"]:checked').each(function () {
          selectedIds.push($(this).val());
        });

        if (selectedIds.length > 0) {
          $.ajax({
            url: 'delete_transactions.php', // Replace with your server-side delete handler
            type: 'POST',
            data: { transaction_ids: selectedIds },
            success: function (response) {
              // Hide the modal and reload the page or table data to reflect the deletions
              $('#deleteConfirmationModal').modal('hide');
              location.reload();
            },
            error: function (xhr, status, error) {
              console.error('Error deleting transactions:', error);
            }
          });
        } else {
          $('#deleteConfirmationModal').modal('hide');
        }
      });
    });

  </script>
</body>

</html>