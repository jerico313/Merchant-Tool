<?php require_once ("../header.php"); ?>

<?php
function displayOrder($store_id = null, $startDate = null, $endDate = null, $billStatus = null)
{
  include ("../inc/config.php");

  // Base SQL query
  $sql = "
        SELECT t.transaction_id, s.store_name, t.promo_code, t.customer_id, t.customer_name, 
               t.transaction_date, t.gross_amount, t.discount, t.amount_discounted, t.amount_paid, t.payment, t.comm_rate_base, t.bill_status
        FROM transaction t
        JOIN store s ON t.store_id = s.store_id
        WHERE 1=1
    ";
  $params = array();

  // Append date range filter if both startDate and endDate are provided
  if ($startDate && $endDate) {
    $sql .= " AND t.transaction_date BETWEEN ? AND ?";
    $params[] = $startDate;
    $params[] = $endDate;
  }

  // Append bill status filter if specified
  if ($billStatus) {
    $sql .= " AND t.bill_status = ?";
    $params[] = $billStatus;
  }

  // Order by transaction date in descending order
  $sql .= " ORDER BY t.transaction_date DESC";

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
      $shortTransactionId = substr($row['transaction_id'], 0, 8);
      $gross_amount = number_format($row['gross_amount'], 2);
      $amount_discounted = number_format($row['amount_discounted'], 2);
      $amount_paid = number_format($row['amount_paid'], 2);
      $discount = number_format($row['discount'], 2);
      $comm_rate_base = number_format($row['comm_rate_base'], 2);

      echo "<tr style='padding:20px 0;' data-id='" . $row['transaction_id'] . "'>";
      echo "<td style='text-align:center;'>" . $shortTransactionId . "</td>";
      echo "<td style='text-align:center;'>" . $row['store_name'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['promo_code'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['customer_id'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['customer_name'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['transaction_date'] . "</td>";
      echo "<td style='text-align:center;'>" . $gross_amount . "</td>";
      echo "<td style='text-align:center;'>" . $discount . "</td>";
      echo "<td style='text-align:center;'>" . $amount_discounted . "</td>";
      echo "<td style='text-align:center;'>" . $amount_paid . "</td>";
      echo "<td style='text-align:center;'>" . $row['payment'] . "</td>";
      echo "<td style='text-align:center;'>" . $comm_rate_base . "</td>";
      echo "<td style='text-align:center;'>" . $row['bill_status'] . "</td>";
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

    .title{
      font-size: 25px;
      padding-left: 2vh;
      padding-top:10px;
    }
  
    .add-btns{
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

        </div>
        <div class="content">
          <div class="table-container">
            <table id="example" class="table bord" style="width:180%;">
              <thead>
                <tr>
                  <th class="first-col">Transaction ID</th>
                  <th>Store Name</th>
                  <th>Promo Code</th>
                  <th>Customer ID</th>
                  <th>Customer Name</th>
                  <th>Transaction Date</th>
                  <th>Gross Amount</th>
                  <th>Discount</th>
                  <th>Amount Discounted</th>
                  <th>Amount Paid</th>
                  <th>Payment</th>
                  <th>Commission Rate Base</th>
                  <th class="action-col">Bill Status</th>
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

  <script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
  <script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
  <script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
  <script src="./js/script.js"></script>



<script>
$(window).on('load', function() {
   $('.loading').hide();
   $('.cont-box').show();

   var table = $('#example').DataTable({
      scrollX: true,
      order: [[5, 'asc']]
   }); 

      $.fn.dataTable.ext.search.push(
        function (settings, data, dataIndex) {
          var startDate = $('#startDate').val();
          var endDate = $('#endDate').val();
          var date = data[5]; // Index for the transaction date column

          if (startDate && endDate) {
            return (date >= startDate && date <= endDate);
          }
          return true; // If no date range is selected, return all rows
        }
      );

      // Search button click event
      $('#search').on('click', function () {
        table.draw();
      });

      // Voucher Type filter buttons click events
      $('#btnPretrial').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(12).search('PRE-TRIAL', true, false).draw();
      });

      $('#btnBillable').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(12).search('^BILLABLE$', true, false).draw();
      });

      $('#btnNotBillable').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(12).search('^NOT BILLABLE$', true, false).draw();
      });

      // Show All button click event
      $('#btnShowAll').on('click', function () {
        $('#startDate, #endDate').val('');
        table.search('').columns().search('').draw();
      });
    });
  </script>
</body>

</html>