<?php include("../header.php");

function displayOffers($type, $startDate = null, $endDate = null, $voucherType = null, $promoGroup = null, $billStatus = null)
{
    include("../inc/config.php");

    $sql = "SELECT * FROM transaction_summary_view WHERE 1=1";
    $params = array();

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

    $sql .= " ORDER BY `Transaction Date` ASC";

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        die("SQL Error: " . $conn->error);
    }

    if ($params) {
        $stmt->bind_param(str_repeat("s", count($params)), ...$params);
    }

    $stmt->execute();
    $result = $stmt->get_result();

    $count = 1;

    while ($row = $result->fetch_assoc()) {
        $AmounttobeDisbursed = $row['Amount to be Disbursed'];
        if ($AmounttobeDisbursed < 0) {
            $AmounttobeDisbursed = '(' . number_format(-$AmounttobeDisbursed, 2) . ')';
        } else {
            $AmounttobeDisbursed = number_format($AmounttobeDisbursed, 2);
        }

        echo "<tr style='padding:10px;'>";

        if ($type !== 'User') {
            echo "<td style='width:2%;' id='transaction'><input style='accent-color:#E96529;' class='transaction' type='checkbox' name='transaction_ids[]' value='" . $row['Transaction ID'] . "'></td>";
        } else {
            echo "<td style='width:2%;'>$count</td>";
        }

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
        echo "<td style='width:4%;'>" . $row['Commission Amount'] . "</td>";
        echo "<td style='width:4%;'>" . $row['Total Billing'] . "</td>";
        echo "<td style='width:4%;'>" . $row['PG Fee Rate'] . "</td>";
        echo "<td style='width:4%;'>" . $row['PG Fee Amount'] . "</td>";
        echo "<td style='width:3%;'>" . $row['CWT Rate'] . "%" ."</td>";
        echo "<td style='width:5%;'>" . $AmounttobeDisbursed . "</td>";
        echo "<td style='display:none;'>" . $row['Transaction Date'] . "</td>";
        echo "</tr>";

        $count++;
    }

    $stmt->close();
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
    <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <link rel="stylesheet" href="../style.css">
    <link rel="stylesheet" href="../responsive-table-styles/transaction_2.css">
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

                    <div class="dropdown-center">
                        <button class="check-report dropdown-toggle" type="button" id="dropdownMenuButton"
                            data-bs-toggle="dropdown" aria-expanded="false"><i class="fa-solid fa-filter"></i> Filters
                        </button>
                        <div class="dropdown-menu dropdown-menu-center p-4" style="width:300px !important;"
                            aria-labelledby="dropdownMenuButton">
                            <form>
                                <div class="row">
                                    <div class="col-6">
                                        <button type="button" class="btn all mt-2" id="btnShowAll">All</button>
                                        <button type="button" class="btn coupled mt-2" id="btnCoupled">Coupled</button>
                                        <button type="button" class="btn decoupled mt-2"
                                            id="btnDecoupled">Decoupled</button>
                                        <button type="button" class="btn gcash mt-2" id="btnGCash">
                                            <img src="../images/gcash.png"
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
                        <button class="dropdown-toggle dateRange" type="button" id="dropdownMenuButton"
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
                                <button type="button" class="btn btn-primary mt-2" id="search"><i
                                        class="fa-solid fa-magnifying-glass"></i> Search</button>
                            </form>
                        </div>
                    </div>
                    <a href="upload.php"><button type="button" class="btn btn-primary check-report"
                            style="margin-left:10px; width:170px;"><i class="fa-solid fa-upload"></i> Upload
                            Transactions</button></a>
                    <button type="button" class="btn btn-danger delete" id="clearButton" style="margin-left:10px;"><i
                            class="fa-solid fa-trash"></i> Delete</button>
                </div>
                <div class="content">
                    <table id="example" class="table bord" style="width:280%;">
                        <thead>
                            <tr>
                                <?php if ($type === 'User'): ?>
                                    <th class="first-col" id="select">#</th>
                                <?php else: ?>
                                    <th class="first-col" id="select">Select</th>
                                <?php endif; ?>
                                <th class="second-col">Transaction ID</th>
                                <th id="transaction_date">Transaction Date</th>
                                <th id="customer_id">Customer ID</th>
                                <th id="customer_name">Customer Name</th>
                                <th id="promo_code">Promo Code</th>
                                <th id="voucher_type">Voucher Type</th>
                                <th id="promo_category">Promo Category</th>
                                <th id="promo_group">Promo Group</th>
                                <th id="promo_type">Promo Type</th>
                                <th id="gross_amount">Gross Amount</th>
                                <th id="discount">Discount</th>
                                <th id="cart_amount">Cart Amount</th>
                                <th id="mode_of_payment">Mode of Payment</th>
                                <th id="bill_status">Bill Status</th>
                                <th id="commission_type">Commission Type</th>
                                <th id="commission_rate">Commission Rate</th>
                                <th id="commission_amount">Commission Amount</th>
                                <th id="total_billing">Total Billing</th>
                                <th id="pg_fee_rate">PG Fee Rate</th>
                                <th id="pg_fee_amount">PG Fee Amount</th>
                                <th id="cwt_rate">CWT Rate</th>
                                <th class="action-col" id="amount_to_be_disbursed">Amount to be Disbursed</th>
                                <th style="display:none;"></th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayOffers($type); ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="deleteCountModal" tabindex="-1" aria-labelledby="deleteCountModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content" style="border-radius:20px;">
                <div class="modal-header border-0 text-center p-0">

                </div>
                <div class="modal-body" style="text-align:center;">
                    <p class="modal-title" style="text-align:center;color:#cc001b;" id="deleteCountModalLabel">Delete
                        Transaction</p><br>
                    You have selected <span id="selectedCount"></span> transaction(s) for deletion. Are you sure you
                    want to continue?
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

    <div class="modal fade" id="deleteConfirmationModal" tabindex="-1" aria-labelledby="deleteConfirmationModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content" style="border-radius:20px;">
                <div class="modal-header border-0 text-center p-0">
                </div>

                <div class="modal-body" style="text-align:center;">
                    <p class="modal-title" style="text-align:center;color:#cc001b;" id="deleteCountModalLabel">Delete
                        Transaction</p><br>
                    Are you sure you want to delete the selected transaction(s)?
                </div>

                <div class="modal-footer border-0">
                    <div class="row w-100">
                        <div class="col-6">
                            <button type="button" class="btn btn-danger w-100" id="confirmDeleteButton"
                                style="background-color:#cc001b;border:solid #cc001b 2px;border-radius:20px;font-weight:bold;">Delete</button>
                        </div>
                        <div class="col-6">
                            <button type="button" class="btn btn-secondary w-100" data-bs-dismiss="modal"
                                style="border-radius:20px;background-color:#fff;color:#cc001b;border:solid #cc001b 2px;font-weight:bold;">Cancel</button>
                        </div>
                    </div>
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
        $(window).on('load', function () {
            $('.loading').hide();
            $('.cont-box').show();

            var table = $('#example').DataTable({
                scrollX: true,
                columnDefs: [
                    { orderable: false, targets: [0, 1, 3, 6, 10, 11, 12, 13, 16, 17, 18, 19, 20, 21, 22, 23] }
                ],
                order: [[0, 'asc']]
            }); 

            $('body').on('change', 'input.transaction[type="checkbox"]', function () {
                if ($('input.transaction[type="checkbox"]:checked').length > 0) {
                    $('.delete').show();
                } else {
                    $('.delete').hide();
                }
            });

            $.fn.dataTable.ext.search.push(
                function (settings, data, dataIndex) {
                    var startDate = $('#startDate').val();
                    var endDate = $('#endDate').val();
                    var date = data[23];

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
                table.column(6).search('^Coupled$', true, false).draw();
            });

            $('#btnDecoupled').on('click', function () {
                table.search('').columns().search('').draw();
                table.column(6).search('^Decoupled$', true, false).draw();
            });

            $('#btnGCash').on('click', function () {
                table.search('').columns().search('').draw();
                table.column(8).search('^Gcash$', true, false).draw();
            });

            $('#btnPretrial').on('click', function () {
                table.search('').columns().search('').draw();
                table.column(14).search('PRE-TRIAL', true, false).draw();
            });

            $('#btnBillable').on('click', function () {
                table.search('').columns().search('').draw();
                table.column(14).search('^BILLABLE$', true, false).draw();
            });

            $('#btnNotBillable').on('click', function () {
                table.search('').columns().search('').draw();
                table.column(14).search('^NOT BILLABLE$', true, false).draw();
            });

            $('#btnShowAll').on('click', function () {
                $('#startDate, #endDate').val('');
                table.search('').columns().search('').draw();
            });

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

            $('#proceedToDeleteButton').on('click', function () {
                $('#deleteCountModal').modal('hide');
                $('#deleteConfirmationModal').modal('show');
            });

            $('#confirmDeleteButton').on('click', function () {
                var selectedIds = [];
                $('input[name="transaction_ids[]"]:checked').each(function () {
                    selectedIds.push($(this).val());
                });

                if (selectedIds.length > 0) {
                    $.ajax({
                        url: 'delete_transactions.php',
                        type: 'POST',
                        data: { transaction_ids: selectedIds },
                        success: function (response) {
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