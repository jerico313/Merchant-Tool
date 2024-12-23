<?php include("../header.php") ?>
<?php
$fee_id = isset($_GET['fee_id']) ? $_GET['fee_id'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
// $merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_name = isset($_GET['merchant_name']) ? urldecode($_GET['merchant_name']) : '';

function displayFeeHistory($merchant_id)
{
    global $conn, $type;

    $sql = "SELECT * FROM fee_all_view WHERE merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortFeeId = substr($row['fee_id'], 0, 8);
            $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');

            echo "<tr data-id='" . $row['fee_id'] . "'>";
            echo "<td>" . $shortFeeId . "</td>";
            echo "<td>" . $row['paymaya_credit_card'] . "%" . "</td>";
            echo "<td>" . $row['gcash'] . "%" . "</td>";
            echo "<td>" . $row['gcash_miniapp'] . "%" . "</td>";
            echo "<td>" . $row['paymaya'] . "%" . "</td>";
            echo "<td>" . $row['maya_checkout'] . "%" . "</td>";
            echo "<td>" . $row['maya'] . "%" . "</td>";
            echo "<td>" . $row['lead_gen_commission'] . "%" . "</td>";
            echo "<td>" . $row['commission_type'] . "</td>";
            echo "<td>" . $row['effective_date'] . "</td>";
            echo "<td style='display:none;'>" . $merchant_id . "</td>";
            if ($type !== 'User') {
                echo "<td class='actions-cell;'>";
                echo "<a href='#' onclick='editFee(\"" . $row['fee_id'] . "\")' style='color:#E96529;pointer'>Edit</a>";
                echo "</td>";
            }
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
    <title><?php echo htmlspecialchars($merchant_name); ?> - Fee History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="../style.css">
    <link rel="stylesheet" href="../responsive-table-styles/fee_history.css">
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
                <div class="voucher-type">
                    <div class="row title" aria-label="breadcrumb">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                                <li class="breadcrumb-item"><a href="index.php"
                                        style="color:#E96529; font-size:14px;">Fees</a></li>
                                <li class="breadcrumb-item"><a href="#" onclick="location.reload();"
                                        style="color:#E96529; font-size:14px;">History</a></li>
                            </ol>
                        </nav>
                    </div>
                </div>
                <div class="add-btns">
                    <p class="title2"><?php echo htmlspecialchars($merchant_name); ?></p>
                </div>
                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:100%;">
                        <thead>
                            <tr>
                                <th class="first-col">Fee ID</th>
                                <th>Paymaya Credit Card</th>
                                <th>Gcash</th>
                                <th>Gcash Miniapp</th>
                                <th>Paymaya</th>
                                <th>Maya Checkout</th>
                                <th>Maya</th>
                                <th>Leadgen Commission</th>
                                <th>Commission Type</th>
                                <th>Effective Date</th>
                                <th style="display:none;"></th>
                                <th class="action-col" style="width:8%;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayFeeHistory($merchant_id); ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editFeeModal" data-bs-backdrop="static" tabindex="-1"
        aria-labelledby="editFeeModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius:20px;">
                <div class="modal-header border-0">
                    <p class="modal-title" id="editFeeModalLabel">Edit Fee Details</p>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editFeeForm" action="edit.php" method="POST">
                        <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
                        <input type="hidden" id="merchantId" name="merchantId"
                            value="<?php echo htmlspecialchars($merchant_id); ?>">
                        <input type="hidden" id="merchantName" name="merchantName"
                            value="<?php echo htmlspecialchars($merchant_name); ?>">

                        <div class="mb-3">
                            <label for="feeId" class="form-label">
                                Fee ID
                            </label>
                            <input type="text" class="form-control" id="feeId" name="feeId" disabled>
                        </div>
                        <div class="mb-3">
                            <label for="paymayaCreditCard" class="form-label">
                                Paymaya Credit Card, Maya Checkout, & Maya
                                <span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <div class="input-group">
                                <input type="number" step="0.01" class="form-control" id="paymayaCreditCard"
                                    name="paymayaCreditCard" min="0.00" placeholder="0.00" required>
                                <span class="input-group-text">%</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="gcash" class="form-label">Gcash<span class="text-danger"
                                    style="padding:2px">*</span></label>
                            <div class="input-group">
                                <input type="number" step="0.01" class="form-control" id="gcash" name="gcash" min="0.00"
                                    placeholder="0.00" required>
                                <span class="input-group-text">%</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="gcashMiniapp" class="form-label">Gcash Miniapp<span class="text-danger"
                                    style="padding:2px">*</span></label>
                            <div class="input-group">
                                <input type="number" step="0.01" class="form-control" id="gcashMiniapp"
                                    name="gcashMiniapp" min="0.00" placeholder="0.00" required>
                                <span class="input-group-text">%</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="paymaya" class="form-label">Paymaya<span class="text-danger"
                                    style="padding:2px">*</span></label>
                            <div class="input-group">
                                <input type="number" step="0.01" class="form-control" id="paymaya" name="paymaya"
                                    min="0.00" placeholder="0.00" required>
                                <span class="input-group-text">%</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="leadgenCommission" class="form-label">Leadgen Commission<span
                                    class="text-danger" style="padding:2px">*</span></label>
                            <div class="input-group">
                                <input type="number" step="0.01" class="form-control" id="leadgenCommission"
                                    name="leadgenCommission" min="0.00" placeholder="0.00" required>
                                <span class="input-group-text">%</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="commissionType" class="form-label">Commission Type<span class="text-danger"
                                    style="padding:2px">*</span></label>
                            <select class="form-select" id="commissionType" name="commissionType" required>
                                <option selected disabled>-- Select Commission Type --</option>
                                <option value="VAT Inc">VAT Inc</option>
                                <option value="VAT Exc">VAT Exc</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="effectiveDate" class="form-label">
                                Effective Date<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input type="date" class="form-control" id="effectiveDate" name="effectiveDate" required>
                        </div>
                        <button type="submit" class="btn btn-primary modal-save-btn">Save changes</button>
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
        $(window).on('load', function () {
            $('.loading').hide();
            $('.cont-box').show();

            var table = $('#example').DataTable({
                scrollX: true,
                columnDefs: [
                    { orderable: false, targets: [11] }
                ],
                order: [[9, 'desc']]
            });
        });
    </script>

    <script>
        function editFee(feeUuid) {
            var feeRow = $('#dynamicTableBody').find('tr[data-id="' + feeUuid + '"]');
            var feeId = feeRow.attr('data-id');
            var paymayaCreditCard = feeRow.find('td:nth-child(2)').text().replace('%', '').trim();
            var gcash = feeRow.find('td:nth-child(3)').text().replace('%', '').trim();
            var gcashMiniapp = feeRow.find('td:nth-child(4)').text().replace('%', '').trim();
            var paymaya = feeRow.find('td:nth-child(5)').text().replace('%', '').trim();
            var mayaCheckout = feeRow.find('td:nth-child(6)').text().replace('%', '').trim();
            var maya = feeRow.find('td:nth-child(7)').text().replace('%', '').trim();
            var leadgenCommission = feeRow.find('td:nth-child(8)').text().replace('%', '').trim();
            var commissionType = feeRow.find('td:nth-child(9)').text();
            var effectiveDate = feeRow.find('td:nth-child(10)').text();
            var merchantId = feeRow.find('td:nth-child(11)').text();
            var merchantName = "<?php echo $merchant_name; ?>";
            console.log("Merchant Name: ", merchantName); // Log the merchant name

            $('#feeId').val(feeId);
            $('#paymayaCreditCard').val(paymayaCreditCard);
            $('#gcash').val(gcash);
            $('#gcashMiniapp').val(gcashMiniapp);
            $('#paymaya').val(paymaya);
            $('#mayaCheckout').val(mayaCheckout);
            $('#maya').val(maya);
            $('#leadgenCommission').val(leadgenCommission);
            $('#commissionType').val(commissionType);
            $('#effectiveDate').val(effectiveDate);
            $('#merchantId').val(merchantId);
            $('#merchantName').val(merchantName);

            $('#editFeeModal').modal('show');
        }
    </script>
</body>

</html>