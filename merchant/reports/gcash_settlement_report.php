<?php
include ('../../inc/config.php');

$gcash_report_id = isset($_GET['gcash_report_id']) ? $_GET['gcash_report_id'] : '';

function displayReportHistoryGcashBody($gcash_report_id)
{
  include ("../../inc/config.php");

  $sql = "SELECT * FROM report_history_gcash_body WHERE gcash_report_id = ?";
  $stmt = $conn->prepare($sql);
  $stmt->bind_param("s", $gcash_report_id);
  $stmt->execute();
  $result = $stmt->get_result();

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $netAmount = number_format($row['net_amount'], 2);
      echo "<tr>";
      echo "<td style='text-align:center;'>" . $row['item'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['quantity_redeemed'] . "</td>";
      echo "<td style='text-align:center;'>" . $netAmount . "</td>";
      echo "</tr>";
    }
  }

  $conn->close();
}

function displayQuantity($gcash_report_id)
{
  include ("../../inc/config.php");

  $sql = "SELECT * FROM report_history_gcash_body WHERE gcash_report_id = ?";
  $stmt = $conn->prepare($sql);
  $stmt->bind_param("s", $gcash_report_id);
  $stmt->execute();
  $result = $stmt->get_result();

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $netAmount = number_format($row['net_amount'], 2);
      echo "<tr>";
      echo "<td style='text-align:center;'>" . $row['item'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['quantity_redeemed'] . "</td>";
      echo "<td style='text-align:center;display:none;'>" . $netAmount . "</td>";
      echo "</tr>";
    }
  }

  $conn->close();
}
// Fetch data from the database
$sql = "SELECT * FROM report_history_gcash_head WHERE gcash_report_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $gcash_report_id);
$stmt->execute();
$result = $stmt->get_result();
$data = $result->fetch_assoc();
$stmt->close();
$conn->close();

$merchant_brand_name = str_replace("'", "", $data['merchant_brand_name']);
$totalAmount = number_format($data['total_amount'], 2);
$commissionAmount = number_format($data['commission_amount'], 2);
$vatAmount = number_format($data['vat_amount'], 2);
$totalCommissionFees = number_format($data['total_commission_fees'], 2);

$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$end_date = isset($_GET['settlement_period_end']) ? $_GET['settlement_period_end'] : '';
$start_date = isset($_GET['settlement_period_start']) ? $_GET['settlement_period_start'] : '';
$bill_status = isset($_GET['bill_status']) ? $_GET['bill_status'] : '';

function displayOffers($merchant_id, $start_date, $end_date, $bill_status)
{
  include ("../../inc/config.php");

  // Base SQL query
  $sql = "SELECT * FROM transaction_summary_view 
            WHERE `Merchant ID` = ? 
            AND `Transaction Date` BETWEEN ? AND ?";

  // Adjust SQL query based on the bill_status parameter
  if ($bill_status === 'BILLABLE') {
    $sql .= " AND `Bill Status` = 'BILLABLE'";
  } elseif ($bill_status === 'PRE-TRIAL') {
    $sql .= " AND `Bill Status` = 'PRE-TRIAL'";
  } elseif ($bill_status === 'All') {
    $sql .= " AND `Bill Status` IN ('BILLABLE', 'PRE-TRIAL')";
  }

  $stmt = $conn->prepare($sql);

  if (!$stmt) {
    die("Prepare failed: (" . $conn->errno . ") " . $conn->error);
  }

  // Bind parameters without bill_status as it's already in the query
  $stmt->bind_param("sss", $merchant_id, $start_date, $end_date);

  if (!$stmt->execute()) {
    die("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
  }

  $result = $stmt->get_result();

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      if ($row['Promo Group'] == "Gcash") {
        $GrossAmount = number_format($row['Gross Amount'], 2);
        $Discount = number_format($row['Discount'], 2);
        $CartAmount = number_format($row['Cart Amount'], 2);
        $CommissionAmount = number_format($row['Commission Amount'], 2);
        $TotalBilling = number_format($row['Total Billing'], 2);
        $PGFeeAmount = number_format($row['PG Fee Amount'], 2);

        $AmounttobeDisbursed = $row['Amount to be Disbursed'];
        if ($AmounttobeDisbursed < 0) {
          $AmounttobeDisbursed = '(' . number_format(-$AmounttobeDisbursed, 2) . ')';
        } else {
          $AmounttobeDisbursed = number_format($AmounttobeDisbursed, 2);
        }

        $date = new DateTime($row['Transaction Date']);
        $formattedDate = $date->format('F d, Y g:i A');
        echo "<tr style='padding:10px;color:#fff;'>";
        echo "<td style='text-align:center;width:4%;'>" . $row['Transaction ID'] . "</td>";
        echo "<td style='text-align:center;width:7%;'>" . $formattedDate . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $row['Customer ID'] . "</td>";
        echo "<td style='text-align:center;width:7%;'>" . $row['Customer Name'] . "</td>";
        echo "<td style='text-align:center;width:5%;'>" . $row['Promo Code'] . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $GrossAmount . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $Discount . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $CartAmount . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $row['Mode of Payment'] . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $row['Bill Status'] . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $row['Commission Type'] . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $row['Commission Rate'] . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $CommissionAmount . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $TotalBilling . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $row['PG Fee Rate'] . "</td>";
        echo "<td style='text-align:center;width:4%;'>" . $PGFeeAmount . "</td>";
        echo "<td style='text-align:center;width:5%;'>" . $AmounttobeDisbursed . "</td>";
        echo "</tr>";
      }
    }
  } else {
    echo "No results found.";
  }

  $stmt->close();
  $conn->close();
}
?>
<!DOCTYPE html>
<html>

<head>
  <meta charset="UTF-8">
  <title><?php echo htmlspecialchars($data['merchant_brand_name']); ?> -
    <?php echo htmlspecialchars($data['settlement_period']); ?> -
    (<?php echo htmlspecialchars($data['settlement_number']); ?>)
    <?php echo htmlspecialchars($data['bill_status']); ?>.pdf</title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/5.0.0-alpha1/css/bootstrap.min.css">
  <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.68/pdfmake.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.68/vfs_fonts.js"></script>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link
    href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,500;1,500&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap"
    rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.16.9/xlsx.full.min.js"></script>
  <style>
    * {
      font-family: "Nunito", sans-serif;
      font-size: 11px;
      margin: 0;
      padding: 0;
    }

    body {
      background-color: #636363;
    }

    td {
      padding-top: 2px;
      padding-bottom: 2px;
    }

    .container {
      background-color: #fff;
      box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.50);
      -webkit-box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.50);
      -moz-box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.50);
      height: 1100px;
      width: 850px;
      margin-top: 120px;
      margin-bottom: 50px;
    }

    #downloadBtn,
    #downloadBtnExcel,
    #print {
      padding: 8px 20px;
      background-color: transparent;
      color: #fff;
      border: none;
      cursor: pointer;
      font-size: 13px;
      text-decoration: none;
    }


    nav {
      opacity: 0.8;
      box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.25);
      -webkit-box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.25);
      -moz-box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.25);
    }

    p {
      padding: 0px;
      margin: 4px;
    }

    @media print {
      @page {
        size: auto;
        margin: 8mm;
      }

      body {
        margin: 25px;
      }
    }
  </style>
</head>

<body>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark pt-3 pb-3 pl-3 pr-3 fixed-top">
    <div class="container-fluid">
      <a class="navbar-brand" href="javascript:history.back()">
        <i class="fa-solid fa-arrow-left fa-lg"></i>
        <span
          style="margin-left:10px;font-size:8px;background-color:#EA4335;padding:4px;border-radius:5px;font-family:helvetica;font-weight:bold;">PDF</span>
        <?php echo htmlspecialchars($data['merchant_brand_name']); ?> -
        <?php echo htmlspecialchars($data['settlement_period']); ?> -
        (<?php echo htmlspecialchars($data['settlement_number']); ?>)
        <?php echo htmlspecialchars($data['bill_status']); ?>.pdf
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"
        aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
        <ul class="navbar-nav">
          <!-- Add your navigation items here if needed -->
        </ul>
        <a class="print" id="print" href="#"><i class="fa-solid fa-print fa-lg"></i> Print</a>
        <a class="downloadBtnExcel" id="downloadBtnExcel" onclick="downloadTables()" href="#"><i
            class="fa-solid fa-download fa-lg"></i> CSV</a>
        <!-- <a class="downloadBtn" id="downloadBtn"  href="#"> <i class="fa-solid fa-download fa-lg"></i> PDF</a>-->
      </div>
    </div>
  </nav>
  <div class="box" style="display:none;">
    <table id="transaction" class="table bord" style="width:250%;">
      <thead>
        <tr>
          <th>Transaction ID</th>
          <th>Transaction Date</th>
          <th>Customer ID</th>
          <th>Customer Name</th>
          <th>Promo Code</th>
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
          <th>Amount to be Disbursed</th>
        </tr>
      </thead>
      <tbody id="dynamicTableBody">
        <?php displayOffers($merchant_id, $start_date, $end_date, $bill_status); ?>
      </tbody>
    </table>
  </div>
  <div class="container" style="padding:70px;" id="content">
    <p style="text-align:center;font-size:20px;font-weight:900;">SETTLEMENT REPORT</p>
    <p class="text-right" style="font-weight:bold;font-size:40px;">
      <img src="../../images/booky2.png" alt="booky" width="150" height="50">
    </p>
    <table style="width:100% !important;">
      <tr>
        <td>Business Name: <span
            style="margin-left:15px;font-weight:bold;"><?php echo htmlspecialchars($data['merchant_business_name'] ?? '', ENT_QUOTES, 'UTF-8'); ?></span>
        <td style="width:40%;">Settlement Date: <span
            style="margin-left:21px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_date']); ?></span>
        </td>
      </tr>
      <tr>
        <td>Brand Name: <span
            style="margin-left:29px;font-weight:bold;"><?php echo htmlspecialchars($data['merchant_brand_name']); ?></span>
        </td>
        <td>Settlement Number: <span
            style="margin-left:5px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_number']); ?></span>
        </td>
      </tr>
      <tr>
        <td>Business Address: <span
            style="margin-left:2px;font-weight:bold;"><?php echo htmlspecialchars($data['business_address'] ?? '', ENT_QUOTES, 'UTF-8'); ?></span>
        </td>
        <td>Settlement Period: <span
            style="margin-left:15px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_period']); ?></span>
        </td>
      </tr>
    </table>
    <hr style="border: 1px solid #3b3b3b;">
    <p style="text-align:center;font-weight:bold;">Gcash Lead Generation</p>
    <hr style="border: 1px solid #3b3b3b;">
    <table id="example" style="width:100%;">
      <thead>
        <tr>
          <td style="text-align:center;font-weight:bold;">Items</td>
          <td style="text-align:center;font-weight:bold;">Qty Redeemed</td>
          <td style="text-align:center;font-weight:bold;">Net Total</td>
        </tr>
      </thead>
      <tbody id="dynamicTableBody">
        <?php displayReportHistoryGcashBody($gcash_report_id); ?>
      </tbody>
      <tfoot>
        <tr>
          <td style="text-align:center;font-weight:bold;"></td>
          <td style="text-align:center;font-weight:bold;"></td>
          <td style="text-align:center;font-weight:bold;"><?php echo $totalAmount; ?></td>
        </tr>

      </tfoot>
    </table>
    <hr style="border: 1px solid #3b3b3b;">
    <table id="example" style="width:100%;">
      <thead>
        <tr>
          <td style="text-align:center;font-weight:bold;">Items</td>
          <td style="text-align:center;font-weight:bold;">Qty Redeemed</td>
          <td style="text-align:center;font-weight:bold;width:27.5%;"></td>
        </tr>
      </thead>
      <tbody id="dynamicTableBody">
        <?php displayQuantity($gcash_report_id); ?>
      </tbody>
    </table>
    <table style="width:100% !important;">
      <tr>
        <td style="text-align:right;width:80%;">Commission (<?php echo htmlspecialchars($data['commission_rate']); ?>)</td>
        <td style="text-align:right;width:20%;padding-right:70px;"><?php echo $commissionAmount; ?></td>
      </tr>
      <tr>

        <td style="text-align:right;width:80%;">VAT (12%)</td>
        <td style="text-align:right;width:20%;padding-right:70px;"><?php echo $vatAmount; ?></td>
      </tr>
      <tr>
        <td style="text-align:right;width:80%;"></td>
        <td style="text-align:right;width:20%;font-weight:bold;padding-right:70px;"><?php echo $totalCommissionFees; ?>
        </td>
      </tr>
    </table>
    <br>
    <table style="width:100% !important;">
      <tr>
        <td style="text-align:left;font-weight:bold;">Total Commission Fees</td>
        <td style="text-align:right;font-weight:bold;padding-right:70px;"><?php echo $totalCommissionFees; ?></td>
      </tr>
    </table>

    <hr style="border: 1px solid #3b3b3b;">
    <p>This is a system generated report and doesn't require a signature. If you have questions feel free to contact us
      at 632-34917659 loc. 7663 or email us at accounting@phonebooky.com</p>
    <br>
    <p>Scrambled Eggs Software Inc. </p>
    <p>Unit D1 2/F 603 REY-D BUILDING </p>
    <p>San Rafael St. cor. Boni Avenue Bgy. Plainview Mandaluyong City 1550 Philippines</p>
    <p>T: (632) 34917659 </p>
  </div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.9.2/html2pdf.bundle.min.js">
  </script>

  <script>
    window.onload = function () {
      document.getElementById("downloadBtn").addEventListener("click", () => {
        const invoice = document.getElementById("content");
        var opt = {
          margin: [-1.5, -0.5, -0.5, -0.5], // [top, right, bottom, left] in inches
          filename: '<?php echo htmlspecialchars($data['merchant_business_name']); ?> - <?php echo htmlspecialchars($data['settlement_period']); ?> - (<?php echo htmlspecialchars($data['settlement_number']); ?>).pdf',
          image: { type: 'jpeg', quality: 1.0 },
          html2canvas: { scale: 5 },
          jsPDF: { unit: 'in', format: 'A4', orientation: 'portrait' }
        };
        html2pdf().from(invoice).set(opt).save();
      });
    }
  </script>
  <script>
    document.getElementById('print').addEventListener('click', function () {
      const originalContent = document.body.innerHTML;
      const printContent = document.getElementById('content').innerHTML;
      document.body.innerHTML = printContent;

      window.onafterprint = function () {
        document.body.innerHTML = originalContent;
        setTimeout(function () {
          location.reload(); // Reload the page after a short delay
        }, 10); // Adjust the delay duration (in milliseconds) as needed
      };

      window.print();
    });
  </script>
  <script>
    function downloadTables() {
      var table = document.getElementById("transaction");
      var wb = XLSX.utils.table_to_book(table, { sheet: "Sheet1" });
      XLSX.writeFile(wb, "<?php echo $data['merchant_brand_name']; ?> - <?php echo htmlspecialchars($data['settlement_period']); ?> - (<?php echo htmlspecialchars($data['settlement_number']); ?>) <?php echo htmlspecialchars($data['bill_status']); ?>.xlsx");
    }
  </script>

</body>

</html>