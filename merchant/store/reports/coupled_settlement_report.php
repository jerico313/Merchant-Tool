<?php
// Include the configuration file
include ('../../../inc/config.php');

$coupled_report_id = isset($_GET['coupled_report_id']) ? $_GET['coupled_report_id'] : '';

// Fetch data from the database
$sql = "SELECT * FROM report_history_coupled WHERE coupled_report_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $coupled_report_id);
$stmt->execute();
$result = $stmt->get_result();
$data = $result->fetch_assoc();
$stmt->close();
$conn->close();

$totalGrossSales = number_format($data['total_gross_sales'], 2);
$totalDiscount = number_format($data['total_discount'], 2);
$totalOutstandingAmount1 = number_format($data['total_outstanding_amount_1'], 2);
$leadgenCommissionRateBasePretrial = number_format($data['leadgen_commission_rate_base_pretrial'], 2);
$totalCommissionFees1 = number_format($data['total_commission_fees_1'], 2);
$leadgenCommissionRateBaseBillable = number_format($data['leadgen_commission_rate_base_billable'], 2);
$totalPretrial = number_format($data['total_pretrial'], 2);
$totalBillable = number_format($data['total_billable'], 2);
$cardPaymentPGFee = number_format($data['card_payment_pg_fee'], 2);
$paymayaPgFee = number_format($data['paymaya_pg_fee'], 2);
$gcashMiniappPGFee = number_format($data['gcash_miniapp_pg_fee'], 2);
$gcashPGFee = number_format($data['gcash_pg_fee'], 2);
$totalPaymentGatewayFees1 = number_format($data['total_payment_gateway_fees_1'], 2);
$totalOutstandingAmount2 = number_format($data['total_outstanding_amount_2'], 2);
$totalCommissionFees2 = number_format($data['total_commission_fees_2'], 2);
$totalPaymentGatewayFees2 = number_format($data['total_payment_gateway_fees_2'], 2);
$bankFees = number_format($data['bank_fees'], 2);
$wtaxFromGrossSales = number_format($data['wtax_from_gross_sales'], 2);
$cwtFromTransactionFees = number_format($data['cwt_from_transaction_fees'], 2);
$cwtFromPgFees = number_format($data['cwt_from_pg_fees'], 2);
$totalAmountPaidOut = number_format($data['total_amount_paid_out'], 2);

$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$end_date = isset($_GET['settlement_period_end']) ? $_GET['settlement_period_end'] : '';
$start_date = isset($_GET['settlement_period_start']) ? $_GET['settlement_period_start'] : '';
$bill_status = isset($_GET['bill_status']) ? $_GET['bill_status'] : '';

function displayOffers($store_id, $start_date, $end_date, $bill_status)
{
    include ("../../../inc/config.php");

    // Base SQL query
    $sql = "SELECT * FROM transaction_summary_view 
            WHERE `Store ID` = ? 
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
    $stmt->bind_param("sss", $store_id, $start_date, $end_date);

    if (!$stmt->execute()) {
        die("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
    }

    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            if ($row['Voucher Type'] == "Coupled") {
                echo "<tr style='padding:10px;color:#fff;'>";
                echo "<td>" . $row['Transaction ID'] . "</td>";
                echo "<td>" . $row['Formatted Transaction Date'] . "</td>";
                echo "<td>" . $row['Customer ID'] . "</td>";
                echo "<td>" . $row['Customer Name'] . "</td>";
                echo "<td>" . $row['Promo Code'] . "</td>";
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
    <title><?php echo htmlspecialchars($data['store_brand_name']); ?> -
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
            box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.25);
            -webkit-box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.25);
            -moz-box-shadow: 1px 2px 6px 2px rgba(0, 0, 0, 0.25);
            opacity: 0.8;
        }

        p {
            padding: 0px;
            margin: 4px;
        }

        @media print {
            @page {
                size: A4;
                margin: 8mm;
            }

            body {
                margin: 25px;
            }
        }
    </style>
    <script>
        function exportToExcel() {
            const table = document.getElementById("myTable");
            const ws = XLSX.utils.table_to_sheet(table);

            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Transactions");

            XLSX.writeFile(wb, "<?php echo $data['store_brand_name']; ?> - <?php echo htmlspecialchars($data['settlement_period']); ?> - (<?php echo htmlspecialchars($data['settlement_number']); ?>) <?php echo htmlspecialchars($data['bill_status']); ?>.xlsx");
        }
    </script>
</head>

<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark pt-3 pb-3 pl-3 pr-3 fixed-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="javascript:history.back()">
                <i class="fa-solid fa-arrow-left fa-lg"></i>
                <span
                    style="margin-left:10px;font-size:8px;background-color:#EA4335;padding:4px;border-radius:5px;font-family:helvetica;font-weight:bold;">PDF</span>
                <?php echo htmlspecialchars($data['store_brand_name']); ?> -
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
                <a class="downloadExcel" id="downloadBtnExcel" onclick="exportToExcel()" href="#"><i
                        class="fa-solid fa-download fa-lg"></i> Excel</a>
                <!--<a class="downloadBtn" id="downloadBtn"  href="#"> <i class="fa-solid fa-download fa-lg"></i> PDF</a>-->
            </div>
        </div>
    </nav>

    <div class="box">
        <table id="myTable" class="table bord" style="width:250%;display:none;">
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
                    <th>Payment</th>
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
                <?php displayOffers($store_id, $start_date, $end_date, $bill_status); ?>
            </tbody>
        </table>
    </div>

    <div class="container" style="padding:70px;" id="content">
        <p style="text-align:center;font-size:20px;font-weight:900;">SETTLEMENT REPORT</p>
        <p class="text-right" style="font-weight:bold;font-size:40px;">
            <img src="../../../images/booky2.png" alt="booky" width="150" height="50">
        </p>
        <table style="width:100% !important;">
            <tr>
                <td>Business Name: <span
                        style="margin-left:15px;font-weight:bold;"><?php echo htmlspecialchars($data['store_business_name']); ?></span>
                </td>
                <td style="width:40%;">Settlement Date: <span
                        style="margin-left:21px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_date']); ?></span>
                </td>
            </tr>
            <tr>
                <td>Brand Name: <span
                        style="margin-left:29px;font-weight:bold;"><?php echo htmlspecialchars($data['store_brand_name']); ?></span>
                </td>
                <td>Settlement Number: <span
                        style="margin-left:5px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_number']); ?></span>
                </td>
            </tr>
            <tr>
                <td>Business Address: <span
                        style="margin-left:2px;font-weight:bold;"><?php echo htmlspecialchars($data['business_address']); ?></span>
                </td>
                <td>Settlement Period: <span
                        style="margin-left:15px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_period']); ?></span>
                </td>
            </tr>
        </table>
        <hr style="border: 1px solid #3b3b3b;">
        <table style="width:100% !important;">
            <tr>
                <td>Total Number of Successful Orders</td>
                <td id="total_successful_orders" style="width:30%;text-align:center;">
                    <?php echo htmlspecialchars($data['total_successful_orders']); ?> order/s
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
                <td style="font-weight:bold;">Total Outstanding Amount:</td>
                <td id="total_net_sales" style="font-weight:bold;text-align:center;">
                    <?php echo $totalOutstandingAmount1; ?> PHP
                </td>
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
                <td style="padding-left:85px;">Leadgen Commission rate base(Pre-Trial)</td>
                <td id="leadgen_commission_rate_base_pretrial" style="width:30%;text-align:right;padding-right:85px;">
                    <?php echo $leadgenCommissionRateBasePretrial; ?>
                </td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Commission fee rate</td>
                <td id="commission_rate_pretrial" style="text-align:right;padding-right:85px;">
                    <?php echo htmlspecialchars($data['commission_rate_pretrial']); ?>
                </td>
            </tr>
            <tr>
                <td style="font-weight:bold;padding-left:85px;">Total</td>
                <td id="total_pretrial" style="font-weight:bold;text-align:right;padding-right:85px;">
                    <?php echo $totalPretrial; ?> PHP
                </td>
            </tr>
        </table>
        <br>

        <table style="width:100% !important;">
            <tr>
                <td style="padding-left:85px;">Leadgen Commission rate base(Billable)</td>
                <td id="leadgen_commission_rate_base_billable" style="text-align:right;padding-right:85px;">
                    <?php echo $leadgenCommissionRateBaseBillable; ?>
                </td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Commission fee rate</td>
                <td id="commission_rate_billable" style="text-align:right;padding-right:85px;">
                    <?php echo htmlspecialchars($data['commission_rate_billable']); ?>
                </td>
            </tr>
            <tr>
                <td style="font-weight:bold;padding-left:85px;">Total</td>
                <td id="total_billable" style="text-align:right;padding-right:85px;font-weight:bold;">
                    <?php echo $totalBillable; ?>
                </td>
            </tr>
        </table>
        <br>
        <table style="width:100% !important;">
            <tr>
                <td style="font-weight:bold;">Total Commision Fees:</td>
                <td id="total_commission_fees" style="font-weight:bold;text-align:right;padding-right:85px;">
                    <?php echo $totalCommissionFees1; ?> PHP
                </td>
            </tr>
        </table>
        <br>
        <table style="width:100% !important;">
            <tr>
                <td style="padding-left:85px;">Payment Gateway Fees</td>
                <td id="leadgen_commission_rate_base_pretrial" style="width:30%;text-align:right;padding-right:85px;">
                </td>
            </tr>
        </table>
        <br>
        <table style="width:100% !important;">
            <tr>
                <td style="padding-left:85px;">Card Payment</td>
                <td id="leadgen_commission_rate_base_pretrial" style="width:30%;text-align:right;padding-right:85px;">
                    <?php echo $cardPaymentPGFee; ?>
                </td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Paymaya</td>
                <td id="commission_rate_pretrial" style="text-align:right;padding-right:85px;">
                    <?php echo $paymayaPgFee; ?>
                </td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Gcash_miniapp</td>
                <td id="total_pretrial" style="text-align:right;padding-right:85px;"><?php echo $gcashMiniappPGFee; ?>
                </td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Gcash</td>
                <td id="total_pretrial" style="text-align:right;padding-right:85px;"><?php echo $gcashPGFee; ?></td>
            </tr>
            <tr>
                <td style="padding-left:85px;font-weight:bold;">Total Payment Gateway Fees</td>
                <td id="total_pretrial" style="text-align:right;padding-right:85px;font-weight:bold;">
                    <?php echo $totalPaymentGatewayFees1; ?>
                </td>
            </tr>
        </table>
        <hr style="border: 1px solid #3b3b3b;">
        <table style="width:100% !important;">
            <tr>
                <td>Payment Outstanding Amount</td>
                <td id="leadgen_commission_rate_base_pretrial" style="width:30%;text-align:right;padding-right:85px;">
                    <?php echo $totalOutstandingAmount2; ?> PHP
                </td>
            </tr>
        </table>
        <table style="width:100% !important;">
            <tr>
                <td>Less:<span style="padding-left:60px;">Total Commission Fees</span></td>
                <td style="text-align:right;padding-right:85px;"><?php echo $totalCommissionFees2; ?> PHP</td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Total Payment Gateway Fees</td>
                <td style="text-align:right;padding-right:85px;"><?php echo $totalPaymentGatewayFees2; ?> PHP</td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Bank Fees</td>
                <td style="text-align:right;padding-right:85px;"><?php echo $bankFees; ?> PHP</td>
            </tr>
            <tr>
                <td style="padding-left:85px;">Wtax from Gross Sales (BIR-RMC-8-2024)</td>
                <td style="text-align:right;padding-right:85px;"><?php echo $wtaxFromGrossSales; ?> PHP</td>
            </tr>
        </table>
        <table style="width:100% !important;">
            <tr>
                <td>Add:<span style="padding-left:61px;">CWT from Transaction Fees</span></td>
                <td style="text-align:right;padding-right:85px;"><?php echo $cwtFromTransactionFees; ?> PHP</td>
            </tr>
            <tr>
                <td style="padding-left:85px;">CWT from PG Fees</td>
                <td style="text-align:right;padding-right:85px;"><?php echo $cwtFromPgFees; ?> PHP</td>
            </tr>
        </table>
        <table style="width:100% !important;">
            <tr>
                <td style="font-weight:bold;">Total Amount Paid Out</td>
                <td id="leadgen_commission_rate_base_pretrial"
                    style="font-weight:bold;width:30%;text-align:right;padding-right:85px;">
                    <?php echo $totalAmountPaidOut; ?> PHP
                </td>
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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.9.2/html2pdf.bundle.min.js"></script>
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

</body>

</html>