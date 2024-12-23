<?php include("../../header.php") ?>
<?php
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';

function displayRateHistory($store_id)
{
    global $conn, $type;

    $sql = "SELECT * FROM cwt_rate_view
            WHERE store_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $store_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortCWTRateId = substr($row['cwt_rate_id'], 0, 8);
            echo "<tr data-id='" . $row['cwt_rate_id'] . "'>";
            echo "<td>" . $shortCWTRateId . "</td>";
            echo "<td>" . $row['cwt_rate'] . "%" . "</td>";
            echo "<td>" . $row['effective_date'] . "</td>";
            if ($type !== 'User') {
                echo "<td class='actions-cell;'>";
                echo "<a href='#' onclick='editRate(\"" . $row['cwt_rate_id'] . "\")' style='color:#E96529;pointer'>Edit</a>";
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
    <title><?php echo htmlspecialchars($store_name); ?> - CWT Rates</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="../../style.css">
    <link rel="stylesheet" href="../../responsive-table-styles/cwt_rate.css">
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
                                <li class="breadcrumb-item">
                                    <a href="../index.php" style="color:#E96529; font-size:14px;">
                                        Stores
                                    </a>
                                </li>
                                <li class="breadcrumb-item">
                                    <a href="#" onclick="location.reload();" style="color:#E96529; font-size:14px;">
                                        CWT Rates
                                    </a>
                                </li>
                            </ol>
                        </nav>
                    </div>
                </div>
                <div class="add-btns">
                    <p class="title2"><?php echo htmlspecialchars($store_name); ?></p>
                    <a
                        href="add.php?store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>">
                        <button type="button" class="btn btn-primary add-merchant">
                            <i class="fa-solid fa-plus"></i> Add CWT Rate
                        </button>
                    </a>
                </div>
                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:100%;">
                        <thead>
                            <tr>
                                <th class="first-col">CWT Rate ID</th>
                                <th>CWT Rate</th>
                                <th>Effective Date</th>
                                <th class="action-col">Action</th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayRateHistory($store_id); ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editRateModal" data-bs-backdrop="static" tabindex="-1"
        aria-labelledby="editRateModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius:20px;">
                <div class="modal-header border-0">
                    <p class="modal-title" id="editRateModalLabel">Edit CWT Rate Details</p>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editRateForm" action="edit.php" method="POST">
                        <input type="hidden" id="storeId" name="storeId" value="<?php echo htmlspecialchars($store_id); ?>">
                        <input type="hidden" id="storeName" name="storeName" value="<?php echo htmlspecialchars($store_name); ?>">
                        <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
                        <div class="mb-3">
                            <label for="cwt_rate_id" class="form-label">
                                CWT Rate ID
                            </label>
                            <input type="text" class="form-control" id="cwt_rate_id" name="cwt_rate_id" disabled>
                        </div>
                        <div class="mb-3">
                            <label for="cwt_rate" class="form-label">
                                CWT Rate
                                <span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <div class="input-group">
                                <input type="number" step="0.01" class="form-control" id="cwt_rate" name="cwt_rate"
                                    min="0.00" placeholder="0.00" required>
                                <span class="input-group-text">%</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="effective_date" class="form-label">
                                Effective Date<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input type="date" class="form-control" id="effective_date" name="effective_date" required>
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
    <script src="../js/script.js"></script>
    <script>
        $(window).on('load', function () {
            $('.loading').hide();
            $('.cont-box').show();

            var table = $('#example').DataTable({
                scrollX: true,
                columnDefs: [
                    { orderable: false, targets: [3] }
                ],
                order: [[2, 'desc']]
            });
        });
    </script>

    <script>
        function editRate(cwt_rate_Uuid) {
            var cwtRateRow = $('#dynamicTableBody').find('tr[data-id="' + cwt_rate_Uuid + '"]');
            var cwt_rate_id = cwtRateRow.attr('data-id');
            var cwt_rate = cwtRateRow.find('td:nth-child(2)').text().replace('%', '').trim();
            var effective_date = cwtRateRow.find('td:nth-child(3)').text();
            var storeId = "<?php echo htmlspecialchars($store_id); ?>";
            var storeName = "<?php echo htmlspecialchars($store_name); ?>"; 

            $('#storeId').val(storeId);
            $('#storeName').val(storeName);
            $('#cwt_rate_id').val(cwt_rate_id);
            $('#cwt_rate').val(cwt_rate);
            $('#effective_date').val(effective_date);

            $('#editRateModal').modal('show');
        }
    </script>
</body>

</html>