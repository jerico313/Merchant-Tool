<?php include ("../../../header.php") ?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';

function displayOffers($store_id, $startDate = null, $endDate = null, $voucherType = null)
{
    include ("../../../inc/config.php");

    $sql = "SELECT * FROM transaction_summary_view WHERE `Store ID` = ?";
    $params = array($store_id);

    // Append date range condition if start date and end date are provided
    if ($startDate && $endDate) {
        // Convert start and end dates to timestamps
        $startTimestamp = strtotime($startDate);
        $endTimestamp = strtotime($endDate);

        // Adjust SQL query to compare timestamps
        $sql .= " AND UNIX_TIMESTAMP(`Transaction Date`) BETWEEN ? AND ?";
        $params[] = $startTimestamp;
        $params[] = $endTimestamp;
    }

    // Append voucher type filter if specified
    if ($voucherType) {
        $sql .= " AND `Voucher Type` = ?";
        $params[] = $voucherType;
    }

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
            $AmounttobeDisbursed = number_format($row['Amount to be Disbursed'], 2);

            $date = new DateTime($row['Transaction Date']);
            $formattedDate = $date->format('F d, Y g:i A');
            echo "<tr style='padding:10px;'>";
            echo "<td style='text-align:center;width:4%;'>" . $row['Transaction ID'] . "</td>";
            echo "<td style='text-align:center;width:7%;'>" . $formattedDate . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $row['Customer ID'] . "</td>";
            echo "<td style='text-align:center;width:7%;'>" . $row['Customer Name'] . "</td>";
            echo "<td style='text-align:center;width:5%;'>" . $row['Promo Code'] . "</td>";
            echo "<td style='text-align:center;width:3%;'>" . $row['Voucher Type'] . "</td>";
            echo "<td style='text-align:center;width:6%;'>" . $row['Promo Category'] . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $row['Promo Group'] . "</td>";
            echo "<td style='text-align:center;width:6%;'>" . $row['Promo Type'] . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $GrossAmount . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $Discount . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $CartAmount . "</td>";
            echo "<td style='text-align:center;width:4%;'>" . $row['Payment'] . "</td>";
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

    $conn->close();
}
?>


<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
                                <li class="breadcrumb-item"><a href="../../index.php"
                                        style="color:#E96529; font-size:14px;">Merchants</a></li>
                                <li class="breadcrumb-item dropdown">
                                    <a href="#" class="dropdown-toggle" role="button" id="storeDropdown"
                                        data-bs-toggle="dropdown" aria-expanded="false"
                                        style="color:#E96529;font-size:14px;">
                                        Stores
                                    </a>
                                    <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                        <li><a class="dropdown-item"
                                                href="../index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers" style="color:#4BB0B8;">Stores</a>
                                        </li>
                                        <li><a class="dropdown-item"
                                                href="../../promo/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Promos</a>
                                        </li>
                                        <li><a class="dropdown-item"
                                                href="../../reports/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Settlement Reports</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="breadcrumb-item"><a href="#" onclick="location.reload();"
                                        style="color:#E96529; font-size:14px;">Transactions</a></li>
                            </ol>
                        </nav>
                        <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);">
                            <?php echo htmlspecialchars($store_name); ?>
                        </p>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-primary dropdown-toggle mt-4" type="button" id="dropdownMenuButton"
                            data-bs-toggle="dropdown" aria-expanded="false"
                            style="width:150px;margin-left:10px;border-radius:20px;height:32px;background-color: #4BB0B8;border:solid #4BB0B8 2px;">
                            <i class="fa-solid fa-filter"></i> Filters
                        </button>
                        <div class="dropdown-menu dropdown-menu-center p-4" aria-labelledby="dropdownMenuButton">
                            <form>
                                <button type="button" class="btn btn-warning all mt-2" id="btnShowAll">All</button>
                                <button type="button" class="btn btn-warning coupled mt-2"
                                    id="btnCoupled">Coupled</button>
                                <button type="button" class="btn btn-warning decoupled mt-2"
                                    id="btnDecoupled">Decoupled</button>
                                <button type="button" class="btn gcash mt-2" id="btnGCash"><img
                                        src="../../../images/gcash.png"
                                        style="width:25px; height:20px; margin-right: 1.20vw;"
                                        alt="gcash"><span>Gcash</span></button>
                            </form>
                        </div>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-primary dropdown-toggle mt-4" type="button" id="dropdownMenuButton"
                            data-bs-toggle="dropdown" aria-expanded="false"
                            style="width:150px;margin-left:10px;border-radius:20px;height:32px;background-color: #E96529;border:solid #E96529 2px;">
                            Select Date Range
                        </button>

                        <div class="dropdown-menu p-4" aria-labelledby="dropdownMenuButton">
                            <form>
                                <div class="form-group">
                                    <label for="startDate">Start Date</label>
                                    <input type="text" class="form-control" id="startDate"
                                        placeholder="Select start date">
                                </div>
                                <div class="form-group mt-3">
                                    <label for="endDate">End Date</label>
                                    <input type="text" class="form-control" id="endDate" placeholder="Select end date">
                                </div>
                                <button type="button" class="btn btn-warning mt-2" id="search"><i
                                        class="fa-solid fa-magnifying-glass"></i> Search</button>
                            </form>
                        </div>
                    </div>
                    <button type="button" onclick="downloadTables()" class="btn btn-warning download-csv mt-4"><i
                            class="fa-solid fa-download"></i> Download</button>
                </div>
                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:250%;">
                        <thead>
                            <tr>
                                <th>Transaction ID</th>
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
                const promoCategory = row[6].replace(/&amp;/g, '&'); // Replace &amp; with &

                return [
                    row[0], `${row[2]}`, row[3], row[4], row[5], `${promoCategory}`,
                    row[6], row[7], row[8], row[9], row[10],
                    row[11], row[12], row[13], row[14], row[15],
                    row[16], row[17], row[18], row[19], row[20]
                ];
            }

            // Extracting all columns data and formatting customer ID
            const filteredData = tableData.map(row => formatDataForExcel(row));

            // Add headers for Excel file
            filteredData.unshift([
                'Transaction ID', 'Transaction Date',
                'Customer ID', 'Customer Name', 'Promo Code', 'Voucher Type', 'Promo Category', 'Promo Group', 'Promo Type',
                'Gross Amount', 'Discount', 'Cart Amount', 'Payment', 'Bill Status', 'Commission Type', 'Commission Rate',
                'Commission Amount', 'Total Billing', 'PG Fee Rate', 'PG Fee Amount', 'Amount to be Disbursed'
            ]);

            // Create a new workbook and add the data to the first sheet
            const wb = XLSX.utils.book_new();
            const ws = XLSX.utils.aoa_to_sheet(filteredData);
            XLSX.utils.book_append_sheet(wb, ws, "Transactions");

            // Generate the Excel file and trigger the download
            XLSX.writeFile(wb, `<?php echo htmlspecialchars($store_name); ?>_${formattedDate}.xlsx`);
        }
    </script>

    <script>
        $(document).ready(function () {
            var table = $('#example').DataTable({
                scrollX: true,
                language: {
                    emptyTable: "No data available in table"
                },
                columnDefs: [
                    { orderable: false, targets: [0, 1, 2, 5, 9, 10, 11, 12, 15, 16, 17, 18, 19, 20] }, // Disable sorting for columns 2, 3, and 4/ Disable search/filter for columns 0, 1, 5, 6
                ],
                order: [] // Disable default sorting
            });

            // Datepicker initialization
            $("#startDate").datepicker({
                dateFormat: "yy-mm-dd"
            });
            $("#endDate").datepicker({
                dateFormat: "yy-mm-dd"
            });

            // Date range search button click event
            $('#search').on('click', function () {
                var startDate = $('#startDate').val();
                var endDate = $('#endDate').val();

                var startTimestamp = new Date(startDate).getTime() / 1000; // Convert to seconds
                var endTimestamp = new Date(endDate).getTime() / 1000; // Convert to seconds

                table.search('').columns().search('').draw();
                table.columns(1).search(startTimestamp + ' to ' + endTimestamp, true, false).draw();
            });

            // Function to clear date range filter
            $('#clearDates').on('click', function () {
                $('#startDate, #endDate').val('');
                table.search('').columns().search('').draw();
            });

            // Voucher Type filter buttons click events
            $('#btnCoupled').on('click', function () {
                table.search('').columns().search('').draw(); // Clear existing search

                // Apply exact search for 'Coupled' voucher type
                table.column(5).search('^Coupled$', true, false).draw();
            });

            $('#btnDecoupled').on('click', function () {
                table.search('').columns().search('').draw(); // Clear existing search

                // Apply exact search for 'Decoupled' voucher type
                table.column(5).search('^Decoupled$', true, false).draw();
            });

            $('#btnGCash').on('click', function () {
                table.search('').columns().search('').draw(); // Clear existing search

                // Apply exact search for 'GCash' voucher type
                table.column(7).search('^Gcash$', true, false).draw();
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