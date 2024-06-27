<?php
include_once ("../../header.php");

$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';


function displayOffers($merchant_id, $merchant_name)
{
    global $conn, $type;
    $sql = "SELECT * FROM promo WHERE merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $escapedMerchantName = htmlspecialchars($merchant_name, ENT_QUOTES, 'UTF-8');
            $shortPromoId = substr($row['promo_id'], 0, 8);
            $promo_amount = number_format($row['promo_amount'], 2);
            echo "<tr data-id='" . $row['promo_id'] . "'>";
            echo "<td style='text-align:center;'>" . $shortPromoId . "</td>";
            echo "<td style='text-align:center;'>" . $row['promo_code'] . "</td>";
            echo "<td style='text-align:center;'>" . $promo_amount . "</td>";
            echo "<td style='text-align:center;'>" . $row['voucher_type'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['promo_category'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['promo_group'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['promo_type'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['promo_details'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['remarks'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['bill_status'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['start_date'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['end_date'] . "</td>";
            echo "<td style='text-align:center;'>";

            // Check if user type is 'user' to hide edit button
            if ($type !== 'User') {
                echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:80px;background-color:#95DD59;color:black;' onclick='editPromo(\"" . $row['promo_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $row['promo_id'] . "\", \"" . $row['promo_code'] . "\")'>Edit</button> ";
            }

            echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:80px;background-color:#E8C0AE;color:black;' onclick='viewHistory(\"" . $row['promo_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $row['promo_id'] . "\", \"" . $row['promo_code'] . "\")'>View History</button> ";
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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="../../style.css">
    <style>
        body {
            background-image: url("../../images/bg_booky.png");
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
                                <li class="breadcrumb-item"><a href="../index.php"
                                        style="color:#E96529; font-size:14px;">Merchants</a></li>
                                <li class="breadcrumb-item dropdown">
                                    <a href="#" class="dropdown-toggle" role="button" id="storeDropdown"
                                        data-bs-toggle="dropdown" aria-expanded="false"
                                        style="color:#E96529;font-size:14px;">
                                        Promos
                                    </a>
                                    <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                        <li><a class="dropdown-item"
                                                href="../store/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Stores</a>
                                        </li>
                                        <li><a class="dropdown-item"
                                                href="../reports/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Settlement Reports</a>
                                        </li>
                                    </ul>
                                </li>
                            </ol>
                        </nav>
                        <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);">
                            <?php echo htmlspecialchars($merchant_name); ?>
                        </p>
                    </div>
                    <a href="upload.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>""><button type="
                        button" class="btn btn-warning add-merchant mt-4"><i class="fa-solid fa-plus"></i> Add
                        Promo</button></a>
                </div>
                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:200%;">
                        <thead>
                            <tr>
                                <th>Promo ID</th>
                                <th>Promo Code</th>
                                <th>Promo Amount</th>
                                <th>Voucher Type</th>
                                <th>Promo Category</th>
                                <th>Promo Group</th>
                                <th>Promo Type</th>
                                <th>Promo Details</th>
                                <th>Remarks</th>
                                <th>Bill Status</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th style='width:50px;'>Action</th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayOffers($merchant_id, $merchant_name); ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <!-- Modal for Editing Store Details -->
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
                        <input type="hidden" id="merchantId" name="merchantId"
                            value="<?php echo htmlspecialchars($merchant_id); ?>">
                        <input type="hidden" id="merchantName" name="merchantName"
                            value="<?php echo htmlspecialchars($merchant_name); ?>">
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
                                <select class="form-select" id="voucherType" required>
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
                                <div class="mt-1">
                                    <input type="checkbox" id="BOGO" name="BOGO" value="BOGO">
                                    <label for="BOGO"> BOGO</label><br>
                                    <input type="checkbox" id="Free item" name="Free_item" value="Free item">
                                    <label for="Free item"> Free Item</label><br>
                                    <input type="checkbox" id="Fixed_discount" name="Fixed_discount"
                                        value="Fixed discount">
                                    <label for="Fixed_discount"> Fixed Discount</label><br>
                                    <input type="checkbox" id="Percent_discount" name="Percent_discount"
                                        value="Percent discount">
                                    <label for="Percent_discount"> Percent Discount</label><br>
                                    <input type="checkbox" id="Bundle" name="Bundle" value="Bundle">
                                    <label for="Bundle"> Bundle</label><br>
                                </div>
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
                scrollX: true
            });
        });

        function viewHistory(storeId, merchantName, promoId, promoCode) {
            window.location.href = 'history.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId) + '&promo_id=' + encodeURIComponent(promoId) + '&promo_code=' + encodeURIComponent(promoCode);
        }
    </script>
    <script>
        function editPromo(promoId) {
            // Fetch the current data of the selected promo
            var promoRow = $('#dynamicTableBody').find('tr[data-id="' + promoId + '"]');
            var promoCode = promoRow.find('td:nth-child(2)').text();
            var promoAmount = promoRow.find('td:nth-child(3)').text();
            var voucherType = promoRow.find('td:nth-child(4)').text();
            var promoCategory = promoRow.find('td:nth-child(5)').text();
            var promoGroup = promoRow.find('td:nth-child(6)').text();
            var promoType = promoRow.find('td:nth-child(7)').text();
            var promoDetails = promoRow.find('td:nth-child(8)').text();
            var remarks = promoRow.find('td:nth-child(9)').text();
            var billStatus = promoRow.find('td:nth-child(10)').text();
            var startDate = promoRow.find('td:nth-child(11)').text();
            var endDate = promoRow.find('td:nth-child(12)').text();
            var merchantId = "<?php echo htmlspecialchars($merchant_id); ?>"; // Set from PHP
            var merchantName = "<?php echo htmlspecialchars($merchant_name); ?>"; // Set from PHP

            $('#promoId').val(promoId);
            $('#promoCode').val(promoCode);
            $('#promoDetails').val(promoDetails);
            $('#promoAmount').val(promoAmount);
            $('#remarks').val(remarks);
            $('#voucherType').val(voucherType);
            $('#billStatus').val(billStatus);
            $('#promoCategory').val(promoCategory);
            $('#promoGroup').val(promoGroup);
            $('#promoType').val(promoType);
            $('#startDate').val(startDate);
            $('#endDate').val(endDate);

            // Check checkboxes based on promo_type
            var promoTypesArray = promoType.split(',').map(item => item.trim());
            promoTypesArray.forEach(type => {
                switch (type) {
                    case 'BOGO':
                        $('#BOGO').prop('checked', true);
                        break;
                    case 'Free Item':
                        $('#Free item').prop('checked', true);
                        break;
                    case 'Fixed Discount':
                        $('#Fixed_discount').prop('checked', true);
                        break;
                    case 'Percent Discount':
                        $('#Percent_discount').prop('checked', true);
                        break;
                    case 'Bundle':
                        $('#Bundle').prop('checked', true);
                        break;
                    default:
                        break;
                }
            });

            // Open the edit modal
            $('#editStoreModal').modal('show');
        }

    </script>
</body>

</html>