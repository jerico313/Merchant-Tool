<?php
include ('../../inc/config.php');

$decoupled_report_id = isset($_GET['decoupled_report_id']) ? $_GET['decoupled_report_id'] : '';

$sql = "SELECT * FROM report_history_decoupled WHERE decoupled_report_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $decoupled_report_id);
$stmt->execute();
$result = $stmt->get_result();
$data = $result->fetch_assoc();
$stmt->close();
$conn->close();

$totalSuccessfulOrders = number_format($data['total_successful_orders'], 0);
$totalGrossSales = number_format($data['total_gross_sales'], 2);
$totalDiscount = number_format($data['total_discount'], 2);
$totalOutstandingAmount = number_format($data['total_outstanding_amount'], 2);
$leadgenCommissionRateBasePretrial = number_format($data['leadgen_commission_rate_base_pretrial'], 2);
$totalPretrial = number_format($data['total_pretrial'], 2);
$leadgenCommissionRateBaseBillable = number_format($data['leadgen_commission_rate_base_billable'], 2);
$totalBillable = number_format($data['total_billable'], 2);
$totalCommissionFees = number_format($data['total_commission_fees'], 2);

$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$end_date = isset($_GET['settlement_period_end']) ? $_GET['settlement_period_end'] : '';
$start_date = isset($_GET['settlement_period_start']) ? $_GET['settlement_period_start'] : '';
$bill_status = isset($_GET['bill_status']) ? $_GET['bill_status'] : '';

function displayOffers($merchant_id, $start_date, $end_date, $bill_status)
{
    include ("../../inc/config.php");

    $sql = "SELECT * FROM transaction_summary_view 
            WHERE `Merchant ID` = ? 
            AND `Transaction Date` BETWEEN ? AND ?";

    if ($bill_status === 'BILLABLE') {
        $sql .= " AND `Bill Status` = 'BILLABLE' ORDER BY `Transaction Date A` ASC";
    } elseif ($bill_status === 'PRE-TRIAL') {
        $sql .= " AND `Bill Status` = 'PRE-TRIAL' ORDER BY `Transaction Date A` ASC";
    } elseif ($bill_status === 'All' || $bill_status === 'PRE-TRIAL+and+BILLABLE') {
        $sql .= " AND `Bill Status` IN ('BILLABLE', 'PRE-TRIAL') ORDER BY `Transaction Date A` ASC";
    }

    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        die("Prepare failed: (" . $conn->errno . ") " . $conn->error);
    }

    $stmt->bind_param("sss", $merchant_id, $start_date, $end_date);

    if (!$stmt->execute()) {
        die("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
    }

    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            if ($row['Voucher Type'] == "Decoupled") {
                echo "<tr>";
                echo "<td>" . $row['Transaction ID'] . "</td>";
                echo "<td>" . $row['Formatted Transaction Date'] . "</td>";
                echo "<td>" . $row['Promo Code'] . "</td>";
                echo "<td>" . $row['Gross Amount'] . "</td>";
                echo "<td>" . $row['Discount'] . "</td>";
                echo "<td>" . $row['Cart Amount'] . "</td>";
                echo "<td>" . $row['Mode of Payment'] . "</td>";
                echo "<td>" . $row['Bill Status'] . "</td>";
                echo "<td>" . $row['Comm Rate Base'] . "</td>";
                echo "<td>" . $row['Commission Rate'] . "</td>";
                echo "<td>" . $row['Total Billing'] . "</td>";
                echo "<td>" . $row['PG Fee Rate'] . "</td>";
                echo "<td>" . $row['PG Fee Amount'] . "</td>";
                echo "<td>" . $row['Amount to be Disbursed'] . "</td>";
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
            padding-top: 1px;
            padding-bottom: 1px;
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
                    style="margin-left:10px;font-size:8px;background-color:#EA4335;padding:3px;border-radius:5px;font-family:helvetica;font-weight:bold;">PDF</span>
                    <?php echo htmlspecialchars($data['merchant_brand_name'] ?? '', ENT_QUOTES, 'UTF-8'); ?> -
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
                </ul>
                <a class="btn" id="print"><i class="fa-solid fa-print fa-lg"></i> Print</a>
                <a class="downloadBtnExcel" id="downloadBtnExcel" onclick="downloadTables()"><i
                        class="fa-solid fa-download fa-lg"></i> Excel</a>
            </div>
        </div>
    </nav>
    <div class="box" style="display:none;">
        <table id="example" class="table bord" style="width:250%;">
            <thead>
                <tr>
                    <th>Transaction ID</th>
                    <th>Transaction Date</th>
                    <th>Promo Code</th>
                    <th>Gross Amount</th>
                    <th>Discount</th>
                    <th>Cart Amount</th>
                    <th>Mode of Payment</th>
                    <th>Bill Status</th>
                    <th>Comm Rate Base</th>
                    <th>Comm Rate</th>
                    <th>Comm Amount (<?php echo htmlspecialchars($data['commission_type']); ?>)</th>
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
        <p class="text-right" style="font-weight:bold;font-size:40px;">
            <img src="../../images/booky2.png" alt="booky" width="150" height="50">
        </p>
        <p style="text-align:center;font-size:16px;font-weight:900;">SETTLEMENT REPORT</p>
        <br>
        <table style="width:100% !important;">
            <tr>
                <td style="width:15%;vertical-align:text-top">Business Name: </td>
                <td style="width:45%;font-weight:bold;vertical-align:text-top"><?php echo htmlspecialchars($data['merchant_business_name'] ?? '', ENT_QUOTES, 'UTF-8'); ?></td>  
                <td style="width:15%;vertical-align:text-top">Settlement Date: </td>
                <td style="width:25%;font-weight:bold;vertical-align:text-top"><?php echo htmlspecialchars($data['settlement_date']); ?></td>
            </tr>
            <tr>
                <td style="vertical-align:text-top">Brand Name: </td>
                <td style="font-weight:bold;vertical-align:text-top"><?php echo htmlspecialchars($data['merchant_brand_name'] ?? '', ENT_QUOTES, 'UTF-8'); ?></td>
                <td style="vertical-align:text-top">Settlement Number: </td>
                <td style="font-weight:bold;vertical-align:text-top"><?php echo htmlspecialchars($data['settlement_number']); ?></td>
            </tr>
            <tr>
                <td style="vertical-align:text-top">Business Address: </td>
                <td style="font-weight:bold;vertical-align:text-top"><?php echo htmlspecialchars($data['business_address'] ?? '', ENT_QUOTES, 'UTF-8'); ?></td>
                <td style="vertical-align:text-top">Settlement Period: </td>
                <td style="font-weight:bold;vertical-align:text-top"><?php echo htmlspecialchars($data['settlement_period']); ?></td>
            </tr>
        </table>
        <hr style="border: 1px solid #3b3b3b;">
        <table style="width:100% !important;">
            <tr>
                <td>Total Number of Successful Orders</td>
                <td id="total_successful_orders" style="width:30%;text-align:center;font-weight:bold">
                    <?php echo $totalSuccessfulOrders; ?> order/s
                </td>
            </tr>
        </table>
        <br>
        <table style="width:100% !important;">
            <tr>
                <td>Total Gross Sales</td>
                <td id="total_gross_sales" style="width:30%;text-align:center;"><?php echo $totalGrossSales; ?> PHP
                </td>
            </tr>
            <tr>
                <td>Total Discount</td>
                <td id="total_discount" style="width:30%;text-align:center;"><?php echo $totalDiscount; ?> PHP</td>
            </tr>
            <tr>
                <td style="font-weight:bold;">Total Outstanding Amount</td>
                <td id="total_net_sales" style="font-weight:bold;text-align:center;">
                    <?php echo $totalOutstandingAmount; ?> PHP</td>
            </tr>
        </table>
        <hr style="border: 1px solid #3b3b3b;">

        <table style="width:100% !important;">
            <tr>
                <td>Commission Fees</td>
                <td></td>
            </tr>
        </table>

        <table style="width:100% !important;">
            <tr>
                <td style="padding-left:85px;">Leadgen Commission rate base (Pre-Trial)</td>
                <td id="leadgen_commission_rate_base_pretrial" style="width:30%;text-align:right;padding-right:85px;">
                    <?php echo $leadgenCommissionRateBasePretrial; ?></td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Commission fee rate</td>
                <td id="commission_rate_pretrial" style="text-align:right;padding-right:85px;">
                    <?php echo htmlspecialchars($data['commission_rate_pretrial']); ?></td>
            </tr>
            <tr>
                <td style="font-weight:bold;padding-left:85px;">Total</td>
                <td id="total_pretrial" style="font-weight:bold;text-align:right;padding-right:85px;">
                    <?php echo $totalPretrial; ?>
                </td>
            </tr>
        </table>
        <br>

        <table style="width:100% !important;">
            <tr>
                <td style="padding-left:85px;">Leadgen Commission rate base (Billable)</td>
                <td id="leadgen_commission_rate_base_billable" style="text-align:right;padding-right:85px;">
                    <?php echo $leadgenCommissionRateBaseBillable; ?></td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Commission fee rate</td>
                <td id="commission_rate_billable" style="text-align:right;padding-right:85px;">
                    <?php echo htmlspecialchars($data['commission_rate_billable']); ?></td>
            </tr>
            <tr>
                <td style="font-weight:bold;padding-left:85px;">Total</td>
                <td id="total_billable" style="text-align:right;padding-right:85px;font-weight:bold;">
                    <?php echo $totalBillable; ?></td>
            </tr>
        </table>
        <br>
        <table style="width:100% !important;">
            <tr>
                <td style="font-weight:bold;">Total Commission Fees</td>
                <td id="total_commission_fees" style="font-weight:bold;text-align:right;padding-right:85px;">
                    <?php echo $totalCommissionFees; ?> PHP</td>
            </tr>
        </table>


        <hr style="border: 1px solid #3b3b3b;">
        <p>This is a system generated report and doesn't require a signature. If you have questions feel free to contact
            us at 632-34917659 loc. 7663 or email us at accounting@phonebooky.com</p>
        <br>
        <p>Scrambled Eggs Software Inc. </p>
        <p>Unit D1 2/F 603 REY-D BUILDING </p>
        <p>San Rafael St. cor. Boni Avenue Bgy. Plainview Mandaluyong City 1550 Philippines</p>
        <p style="margin-bottom:50px;">T: (632) 34917659 </p>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.9.2/html2pdf.bundle.min.js">
    </script>

    <script>
        window.onload = function () {
            document.getElementById("downloadBtn").addEventListener("click", () => {
                const invoice = document.getElementById("content");
                var opt = {
                    margin: [-1.5, -0.5, -0.5, -0.5],
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
                    location.reload();
                }, 10);
            };

            window.print();
        });
    </script>
<script>
    function formatNumber(value) {
        return parseFloat(value).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function downloadTables() {
        var table = document.getElementById("example");
        var rows = table.querySelectorAll("tr");
        var data = [];

        rows.forEach(function(row, rowIndex) {
            var rowData = [];
            var cells = row.querySelectorAll("th, td");

            cells.forEach(function(cell, cellIndex) {
                var cellText = cell.innerText || cell.textContent;

                if (rowIndex !== 0 && (cellIndex === 3 || cellIndex === 4 || cellIndex === 5 || cellIndex === 8 || cellIndex === 9 || cellIndex === 10 || cellIndex === 11 || cellIndex === 12 || cellIndex === 13)) {
                    cellText = formatNumber(cellText);
                }

                rowData.push(cellText);
            });

            data.push(rowData);
        });

        var ws = XLSX.utils.aoa_to_sheet(data);
        var wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Sheet1");

        XLSX.writeFile(wb, "<?php echo $data['merchant_brand_name']; ?> - <?php echo htmlspecialchars($data['settlement_period']); ?> - (<?php echo htmlspecialchars($data['settlement_number']); ?>) <?php echo htmlspecialchars($data['bill_status']); ?>.xlsx");
    }
</script>
</body>
</html>