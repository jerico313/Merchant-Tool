<?php include ("../../header.php") ?>
<?php
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';

function displayOffers($store_id, $startDate = null, $endDate = null, $voucherType = null, $promoGroup = null, $billStatus = null)
{
    include ("../../inc/config.php");

    $sql = "SELECT * FROM transaction_summary_view WHERE `Store ID` = ?";
    $params = array($store_id);

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

    if ($startDate && $endDate) {
        $sql .= " AND `Transaction Date` BETWEEN ? AND ?";
        $params[] = $startDate;
        $params[] = $endDate;
    }

    $stmt = $conn->prepare($sql);
    $stmt->bind_param(str_repeat("s", count($params)), ...$params);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $CommissionAmount = number_format($row['Commission Amount'], 2);
            $TotalBilling = number_format($row['Total Billing'], 2);
            $PGFeeAmount = number_format($row['PG Fee Amount'], 2);

            $AmounttobeDisbursed = $row['Amount to be Disbursed'];
            if ($AmounttobeDisbursed < 0) {
                $AmounttobeDisbursed = '(' . number_format(-$AmounttobeDisbursed, 2) . ')';
            } else {
                $AmounttobeDisbursed = number_format($AmounttobeDisbursed, 2);
            }

            echo "<tr style='padding:10px;'>";
            echo "<td style='width:4%;'>" . $row['Transaction ID'] . "</td>";
            echo "<td style='width:7%;'>" . $row['Formatted Transaction Date'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Customer ID'] . "</td>";
            echo "<td style='width:7%;'>" . $row['Customer Name'] . "</td>";
            echo "<td style='width:5%;'>" . $row['Promo Code'] . "</td>";
            echo "<td style='width:3%;'>" . $row['Voucher Type'] . "</td>";
            echo "<td style='width:6%;'>" . $row['Promo Category'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Promo Group'] . "</td>";
            echo "<td style='width:6%;'>" . $row['Promo Type'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Gross Amount'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Discount'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Cart Amount'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Mode of Payment'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Bill Status'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Commission Type'] . "</td>";
            echo "<td style='width:4%;'>" . $row['Commission Rate'] . "</td>";
            echo "<td style='width:4%;'>" . $CommissionAmount . "</td>";
            echo "<td style='width:4%;'>" . $TotalBilling . "</td>";
            echo "<td style='width:4%;'>" . $row['PG Fee Rate'] . "</td>";
            echo "<td style='width:4%;'>" . $PGFeeAmount . "</td>";
            echo "<td style='width:3%;'>" . $row['CWT Rate'] . "%" . "</td>";
            echo "<td style='width:5%;'>" . $AmounttobeDisbursed . "</td>";
            echo "<td style='display:none;'>" . $row['Transaction Date'] . "</td>";
            echo "</tr>";
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
    <title><?php echo htmlspecialchars($store_name); ?> - Transactions</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <link rel="stylesheet" href="../../style.css">
    <link rel="stylesheet" href="../../responsive-table-styles/transaction.css">
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
                <div class="voucher-type">
                    <div class="row pb-2 title" aria-label="breadcrumb">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                                <li class="breadcrumb-item"><a href="../index.php"
                                        style="color:#E96529; font-size:14px;">Stores</a></li>
                                <li class="breadcrumb-item"><a href="#" onclick="location.reload();"
                                        style="color:#E96529; font-size:14px;">Transactions</a></li>
                            </ol>
                        </nav>
                        <div style="width:650px;">
                            <p class="title2" style="padding-left:3px">
                                <?php echo htmlspecialchars($store_name); ?>
                            </p>
                        </div>
                    </div>
                    <div class="dropdown-center">
                        <button class="check-report dropdown-toggle mt-4" type="button" id="dropdownMenuButton"
                            data-bs-toggle="dropdown" aria-expanded="false"><i class="fa-solid fa-filter"></i> Filters
                        </button>
                        <div class="dropdown-menu dropdown-menu-center p-4" style="width:155px !important;"
                            aria-labelledby="dropdownMenuButton">
                            <form>
                                <div class="row">
                                    <div class="col-6">
                                        <button type="button" class="btn all mt-2" id="btnShowAll">All</button>
                                        <button type="button" class="btn coupled mt-2" id="btnCoupled">Coupled</button>
                                        <button type="button" class="btn decoupled mt-2"
                                            id="btnDecoupled">Decoupled</button>
                                        <button type="button" class="btn gcash mt-2" id="btnGCash">
                                            <img src="../../images/gcash.png"
                                                style="width:25px; height:20px; margin-right: 1.20vw;" alt="gcash">
                                            <span>Gcash</span>
                                        </button>
                                    </div>
                                    <div class="col-6">
                                        <button type="button" class="btn coupled mt-2"
                                            id="btnPretrial">PRE-TRIAL</button>
                                        <button type="button" class="btn decoupled mt-2"
                                            id="btnBillable">BILLABLE</button>
                                        <button type="button" class="btn decoupled mt-2" id="btnNotBillable">NOT
                                            BILLABLE</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="dropdown">
                        <button class="dropdown-toggle dateRange mt-4" type="button" id="dropdownMenuButton"
                            data-bs-toggle="dropdown" aria-expanded="false"><i class="fa-solid fa-calendar"></i> Select
                            Date Range</button>
                        <div class="dropdown-menu p-4" aria-labelledby="dropdownMenuButton">
                            <form id="dateFilterForm">
                                <div class="form-group">
                                    <label for="startDate">Start Date</label>
                                    <input type="date" class="form-control" id="startDate"
                                        placeholder="Select start date" required>
                                </div>

                                <div class="form-group mt-3">
                                    <label for="endDate">End Date</label>
                                    <input type="date" class="form-control" id="endDate" placeholder="Select end date"
                                        required>
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
                    <table id="example" class="table bord" style="width:280%;">
                        <thead>
                            <tr>
                                <th class="first-col">Transaction ID</th>
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
                                <th>CWT Rate</th>
                                <th class="action-col">Amount to be Disbursed</th>
                                <th style="display:none;"></th>
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
            const currentDate = new Date();
            const formattedDate = currentDate.toISOString().split('T')[0]; 

            const table = $('#example').DataTable();

            const filteredData = table.rows({ search: 'applied' }).data().toArray();

            function formatDataForExcel(row) {
                return [
                    row[0], row[1], row[2], row[3], row[4],
                    row[9], row[10], row[11], row[12], row[13],
                    row[15], row[16], row[17], row[18], row[19], row[20], row[21]
                ];
            }

            const formattedRows = filteredData.map(row => formatDataForExcel(row));

            formattedRows.unshift([
                'Transaction ID', 'Transaction Date', 'Customer ID', 'Customer Name', 'Promo Code',
                'Gross Amount', 'Discount', 'Cart Amount', 'Mode of Payment', 'Bill Status', 'Commission Rate',
                'Commission Amount', 'Total Billing', 'PG Fee Rate', 'PG Fee Amount', 'CWT Rate','Amount to be Disbursed'
            ]);

            const wb = XLSX.utils.book_new();
            const ws = XLSX.utils.aoa_to_sheet(formattedRows);
            XLSX.utils.book_append_sheet(wb, ws, "Transactions");

            XLSX.writeFile(wb, `<?php echo $store_name; ?> - ${formattedDate} - Transactions.xlsx`);
        }

        $(window).on('load', function () {
            $('.loading').hide();
            $('.cont-box').show();

            var table = $('#example').DataTable({
                scrollX: true,
                columnDefs: [
                    { orderable: false, targets: [0, 2, 5, 9, 10, 11, 12, 15, 16, 17, 18, 19, 20, 21, 22] }
                ],
                order: [[21, 'asc']]
            });

            $.fn.dataTable.ext.search.push(
                function (settings, data, dataIndex) {
                    var startDate = $('#startDate').val();
                    var endDate = $('#endDate').val();
                    var date = data[22]; 

                    if (startDate && endDate) {
                        return (date >= startDate && date <= endDate);
                    }
                    return true; 
                }
            );

            $('#search').on('click', function () {
                table.draw();
            });

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
                table.column(13).search('^BILLABLE$', true, false).draw();
            });

            $('#btnNotBillable').on('click', function () {
                table.search('').columns().search('').draw();
                table.column(13).search('^NOT BILLABLE$', true, false).draw();
            });

            $('#btnShowAll').on('click', function () {
                $('#startDate, #endDate').val('');
                table.search('').columns().search('').draw();
            });
        });

    </script>