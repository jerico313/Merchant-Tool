<?php include ("../../../header.php") ?>
<?php
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';

function displayOffers($store_id, $startDate = null, $endDate = null, $voucherType = null, $promoGroup = null, $billStatus = null)
{
    include ("../../../inc/config.php");

    $sql = "SELECT * FROM transaction_summary_view WHERE `Store ID` = ?";
    $params = array($store_id);

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
    // Order by Transaction Date in descending order (latest to oldest)
    $sql .= " ORDER BY `Transaction Date` DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param(str_repeat("s", count($params)), ...$params);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $GrossAmount = number_format($row['Gross Amount'], 2);
            $Discount = number_format($row['Discount'], 2);
            $CartAmount = number_format($row['Cart Amount'], 2);
            $CommissionAmount = number_format($row['Commission Amount'], 2);
            $TotalBilling = number_format($row['Total Billing'], 2);
            $PGFeeAmount = number_format($row['PG Fee Amount'], 2);
            $CustomerName = empty($row['Customer Name']) ? '-' : $row['Customer Name'];

            $AmounttobeDisbursed = $row['Amount to be Disbursed'];
            if ($AmounttobeDisbursed < 0) {
                $AmounttobeDisbursed = '(' . number_format(-$AmounttobeDisbursed, 2) . ')';
            } else {
                $AmounttobeDisbursed = number_format($AmounttobeDisbursed, 2);
            }

            echo "<tr style='padding:10px;'>";
            echo "<td style='text-align:center;width:4%;'>" . $row['Transaction ID'] . "</td>";
            echo "<td style='text-align:center;width:7%;'>" . $row['Formatted Transaction Date'] . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $row['Customer ID'] . "</td>";
            echo "<td style='text-align:center;width:7%;'>" . $CustomerName . "</td>";
            echo "<td style='text-align:center;width:5%;'>" . $row['Promo Code'] . "</td>";
            echo "<td style='text-align:center;width:3%;'>" . $row['Voucher Type'] . "</td>";
            echo "<td style='text-align:center;width:6%;'>" . $row['Promo Category'] . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $row['Promo Group'] . "</td>";
            echo "<td style='text-align:center;width:6%;'>" . $row['Promo Type'] . "</td>";
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
            echo "<td style='display:none;'>" . $row['Transaction Date'] . "</td>";
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
    <title><?php echo htmlspecialchars($store_name); ?> - Store Transactions</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <link rel="stylesheet" href="../../../style.css">
    <style>
        body {
            background-image: url("../../../images/bg_booky.png");
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
            color: #4BB0B8;
        }

        .voucher-type {
            padding-bottom: 0px;
            padding-right: 5vh;
            display: flex;
            align-items: center;
        }

        .dropdown-item {
            font-weight: bold;
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
                content: "Transaction ID";
            }

            td:nth-of-type(2):before {
                content: "Transaction Date";
            }

            td:nth-of-type(3):before {
                content: "Customer ID";
            }

            td:nth-of-type(4):before {
                content: "Customer Name";
            }

            td:nth-of-type(5):before {
                content: "Promo Code";
            }

            td:nth-of-type(6):before {
                content: "Voucher Type";
            }

            td:nth-of-type(7):before {
                content: "Promo Category";
            }

            td:nth-of-type(8):before {
                content: "Promo Group";
            }

            td:nth-of-type(9):before {
                content: "Promo Type";
            }

            td:nth-of-type(10):before {
                content: "Gross Amount";
            }

            td:nth-of-type(11):before {
                content: "Discount";
            }

            td:nth-of-type(12):before {
                content: "Cart Amount";
            }

            td:nth-of-type(13):before {
                content: "Mode of Payment";
            }

            td:nth-of-type(14):before {
                content: "Bill Status";
            }

            td:nth-of-type(15):before {
                content: "Commission Type";
            }

            td:nth-of-type(16):before {
                content: "Commission Rate";
            }

            td:nth-of-type(17):before {
                content: "Commission Amount";
            }

            td:nth-of-type(18):before {
                content: "Total Billing";
            }

            td:nth-of-type(19):before {
                content: "PG Fee Rate";
            }

            td:nth-of-type(20):before {
                content: "PG Fee Amount";
            }

            td:nth-of-type(21):before {
                content: "Amount to be Disbursed";
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
                            <li class="breadcrumb-item">
                                <a href="../../../merchant/index.php" style="color:#E96529; font-size:14px;">
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
                                            href="../../store/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                            data-breadcrumb="Offers" style="color:#4BB0B8;"> Stores</a>
                                    </li>
                                    <li><a class="dropdown-item"
                                            href="../../promo/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                            data-breadcrumb="Offers">Promos</a>
                                    </li>
                                </ul>
                            </li>
                            <li class="breadcrumb-item">
                                <a href="#" style="color:#E96529; font-size:14px;">
                                    Store Transactions
                                </a>
                            </li>
                        </ol>
                    </nav>
                        <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);">
                            <?php echo htmlspecialchars($store_name); ?>
                        </p>
                    </div>
                    <div class="dropdown-center">
                    <button class="check-report dropdown-toggle mt-4" type="button" id="dropdownMenuButton"
                        data-bs-toggle="dropdown" aria-expanded="false"><i class="fa-solid fa-filter"></i> Filters
                    </button>
                    <div class="dropdown-menu dropdown-menu-center p-4" style="width:300px !important;" aria-labelledby="dropdownMenuButton">
                        <form>
                            <div class="row">
                                <div class="col-6">
                                    <button type="button" class="btn all mt-2" id="btnShowAll">All</button>
                                    <button type="button" class="btn coupled mt-2" id="btnCoupled">Coupled</button>
                                    <button type="button" class="btn decoupled mt-2" id="btnDecoupled">Decoupled</button>
                                    <button type="button" class="btn gcash mt-2" id="btnGCash">
                                        <img src="../../../images/gcash.png" style="width:25px; height:20px; margin-right: 1.20vw;" alt="gcash">
                                        <span>Gcash</span>
                                    </button>
                                </div>
                                <div class="col-6">
                                    <button type="button" class="btn coupled mt-2" id="btnPretrial">PRE-TRIAL</button>
                                    <button type="button" class="btn decoupled mt-2" id="btnBillable">BILLABLE</button>
                                    <button type="button" class="btn decoupled mt-2" id="btnNotBillable">NOT BILLABLE</button>
                                </div>
                            </div>
                        </form>
                    </div>
                    </div>
                    <div class="dropdown">
                        <button class="dropdown-toggle mt-4 dateRange" type="button" id="dropdownMenuButton"
                            data-bs-toggle="dropdown" aria-expanded="false"><i class="fa-solid fa-calendar"></i> Select Date Range</button>
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
                <button type="button" onclick="downloadTables()" class="btn btn-warning download-csv mt-4">
                    <i class="fa-solid fa-file-excel"></i> Download</button>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:275%;">
                    <thead>
                        <tr>
                            <th style="padding:10px;border-top-left-radius:10px;border-bottom-left-radius:10px;">Transaction ID</th>
                            <th style="padding:10px;">Transaction Date</th>
                            <th style="padding:10px;">Customer ID</th>
                            <th style="padding:10px;">Customer Name</th>
                            <th style="padding:10px;">Promo Code</th>
                            <th style="padding:10px;">Voucher Type</th>
                            <th style="padding:10px;">Promo Category</th>
                            <th style="padding:10px;">Promo Group</th>
                            <th style="padding:10px;">Promo Type</th>
                            <th style="padding:10px;">Gross Amount</th>
                            <th style="padding:10px;">Discount</th>
                            <th style="padding:10px;">Cart Amount</th>
                            <th style="padding:10px;">Mode of Payment</th>
                            <th style="padding:10px;">Bill Status</th>
                            <th style="padding:10px;">Commission Type</th>
                            <th style="padding:10px;">Commission Rate</th>
                            <th style="padding:10px;">Commission Amount</th>
                            <th style="padding:10px;">Total Billing</th>
                            <th style="padding:10px;">PG Fee Rate</th>
                            <th style="padding:10px;">PG Fee Amount</th>
                            <th style="display:none;"></th>
                            <th style="padding:10px;border-top-right-radius:10px;border-bottom-right-radius:10px;">Amount to be Disbursed</th>
                        </tr>
                    </thead>
                    <tbody id="dynamicTableBody">
                        <?php displayOffers($store_id); ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js"></script>
<script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

<script>
    function downloadTables() {
        // Get current date and format it for the file name
        const currentDate = new Date();
        const formattedDate = currentDate.toISOString().split('T')[0]; // Format date for file name

        // Assuming you have initialized DataTable on #example
        const tableData = $('#example').DataTable().rows().data().toArray();

        // Function to format customer ID if needed
        function formatDataForExcel(row) {
            // Replace any HTML entities with their respective characters
            const customerName = row[3].replace('-', '');
            const modeOfPayment = row[12].replace('-', '');

            return [
                row[0],  row[1], row[2], `${customerName}`, row[4],
                row[9], row[10], row[11], `${modeOfPayment}`, row[15],
                row[16], row[17], row[18], row[19], row[20]
            ];
        }

        // Extracting all columns data and formatting customer ID
        const filteredData = tableData.map(row => formatDataForExcel(row));

        // Add headers for Excel file
        filteredData.unshift([
            'Transaction ID', 'Transaction Date', 'Customer ID', 'Customer Name', 'Promo Code', 
            'Gross Amount', 'Discount', 'Cart Amount', 'Mode of Payment', 'Commission Rate',
            'Commission Amount', 'Total Billing', 'PG Fee Rate', 'PG Fee Amount', 'Amount to be Disbursed'
        ]);

        // Create a new workbook and add the data to the first sheet
        const wb = XLSX.utils.book_new();
        const ws = XLSX.utils.aoa_to_sheet(filteredData);
        XLSX.utils.book_append_sheet(wb, ws, "Transactions");

        // Generate the Excel file and trigger the download
        XLSX.writeFile(wb, `<?php echo htmlspecialchars($store_name); ?>_${formattedDate}.xlsx`);
    }

    $(document).ready(function () {
    var table = $('#example').DataTable({
        scrollX: true,
        language: {
            emptyTable: "No data available in table"
        },
        columnDefs: [
            { orderable: false, targets: [0, 1, 2, 5, 9, 10, 11, 12, 15, 16, 17, 18, 19, 20] },
        ],
        order: []
    });

    $.fn.dataTable.ext.search.push(
        function (settings, data, dataIndex) {
            var startDate = $('#startDate').val();
            var endDate = $('#endDate').val();
            var date = data[21]; 

            if (startDate && endDate) {
                return (date >= startDate && date <= endDate);
            }
            return true; 
        }
    );

    // Search button click event
    $('#search').on('click', function () {
        table.draw();
    });

    // Voucher Type filter buttons click events
    $('#btnCoupled').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(5).search('^Coupled$', true, false).draw();
    });

    $('#btnDecoupled').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(5).search('^Decoupled$', true, false).draw();
    });

    $('#btnGCash').on('click', function () {
        table.search('').columns().search('').draw();
        table.column(7).search('^Gcash$', true, false).draw();
    });

    $('#btnPretrial').on('click', function () {
    table.search('').columns().search('').draw();
    table.column(13).search('PRE-TRIAL', true, false).draw();
  });

  $('#btnBillable').on('click', function () {
    table.search('').columns().search('').draw();
    table.column(11).search('^BILLABLE$', true, false).draw();
  });

  $('#btnNotBillable').on('click', function () {
    table.search('').columns().search('').draw();
    table.column(11).search('^NOT BILLABLE$', true, false).draw();
  });

    // Show All button click event
    $('#btnShowAll').on('click', function () {
        $('#startDate, #endDate').val('');
        table.search('').columns().search('').draw();
    });
});

</script>

