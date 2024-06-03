<?php include("header.php")?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

function displayStore($merchant_id) {
    include("inc/config.php");

    $sql = "SELECT store.*, merchant.merchant_name
            FROM store
            JOIN merchant ON store.merchant_id = merchant.merchant_id
            WHERE store.merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            echo "<tr data-uuid='" . $row['store_id'] . "'>";
            echo "<td><center><input type='checkbox' style='accent-color:#E96529;' class='store-checkbox' value='" . $row['store_id'] . "'></center></td>";
            echo "<td style='text-align:center;'>" . $row['store_id'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['store_name'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['legal_entity_name'] . "</td>"; // Assuming legal_entity_name is a column in store table now
            echo "<td style='text-align:center;'>" . $row['store_address'] . "</td>";
            echo "<td style='text-align:center;'>";
            $escapedMerchantName = htmlspecialchars($row['merchant_name'], ENT_QUOTES, 'UTF-8');
            echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedMerchantName . "\")'>View</button> ";
            echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#95DD59;color:black;' onclick='editStore(\"" . $row['store_id'] . "\")'>Edit</button> ";
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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="style.css">
    <style>
        body {
            background-image: url("images/bg_booky.png");
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
                            <li class="breadcrumb-item"><a href="merchant.php" style="color:#E96529; font-size:14px;">Merchant</a></li>
                            <li class="breadcrumb-item dropdown">
                                <a href="#" class="dropdown-toggle" role="button" id="storeDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="color:#E96529;font-size:14px;">
                                Store
                                </a>
                                <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                    <li><a class="dropdown-item" href="offer.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" data-breadcrumb="Offers">Promo</a></li>
                                    <li><a class="dropdown-item" href="category.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>">Category</a></li>
                                </ul>
                            </li>
                        </ol>
                    </nav>
                    <p class="title_store" style="font-size:40px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);"><?php echo htmlspecialchars($merchant_name); ?></p>
                </div>
                <button type="button" class="btn btn-warning check-report mt-4" style="display:none;"><i class="fa-solid fa-print"></i> Check Report</button>
                <a href="upload_store.php"><button type="button" class="btn btn-warning add-merchant mt-4"><i class="fa-solid fa-plus"></i> Add Store</button></a>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:100%;">
                    <thead>
                        <tr>
                            <th><center><input type='checkbox' style='accent-color:#E96529;' class='store-checkbox' id='checkAll'></center></th>
                            <th>Store ID</th>
                            <th>Store Name</th>
                            <th>Legal Entity Name</th>
                            <th>Store Address</th>
                            <th style='width:200px;'>Action</th>
                        </tr>
                    </thead>
                    <tbody id="dynamicTableBody">
                    <?php displayStore($merchant_id); ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editStoreModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="editStoreModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header border-0">
        <p class="modal-title" id="editStoreModalLabel">Edit Store Details</p>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
      <form id="editStoreForm" action="edit_store.php" method="POST">
    <input type="hidden" id="storeId" name="storeId">
    <input type="hidden" id="merchantId" name="merchantId" value="<?php echo htmlspecialchars($merchant_id); ?>">
    <input type="hidden" id="merchantName" name="merchantName" value="<?php echo htmlspecialchars($merchant_name); ?>">
    <div class="mb-3">
        <label for="storeName" class="form-label">Store Name</label>
        <input type="text" class="form-control" id="storeName" name="storeName">
    </div>
    <div class="mb-3">
        <label for="storeAddress" class="form-label">Store Address</label>
        <input type="text" class="form-control" id="storeAddress" name="storeAddress">
    </div>
    <button type="submit" class="btn btn-primary" style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save changes</button>
</form>
    </div>
  </div>
</div>
<script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
<script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
<script src="./js/script.js"></script>
<script>
$(document).ready(function() {
    $('#checkAll').change(function() {
        $('.store-checkbox').prop('checked', $(this).prop('checked'));
        toggleCheckReportButton();
    });

    $('.store-checkbox').change(function() {
        toggleCheckReportButton();
    });

    function toggleCheckReportButton() {
        if ($('.store-checkbox:checked').length > 0) {
            $('.check-report').show();
        } else {
            $('.check-report').hide();
        }
    }

    if ($.fn.DataTable.isDataTable('#example')) {
        $('#example').DataTable().destroy();
    }
    
    $('#example').DataTable({
        scrollX: true
    });
});

function editStore(storeId) {
    // Fetch the current data of the selected store
    var storeRow = $('#dynamicTableBody').find('tr[data-uuid="' + storeId + '"]');
    var storeName = storeRow.find('td:nth-child(3)').text();
    var storeAddress = storeRow.find('td:nth-child(5)').text();
    var merchantId = "<?php echo htmlspecialchars($merchant_id); ?>"; // Set from PHP
    var merchantName = "<?php echo htmlspecialchars($merchant_name); ?>"; // Set from PHP

    // Set values in the edit modal
    $('#storeId').val(storeId);
    $('#storeName').val(storeName);
    $('#storeAddress').val(storeAddress);
    $('#merchantId').val(merchantId);
    $('#merchantName').val(merchantName);

    // Open the edit modal
    $('#editStoreModal').modal('show');
}
</script>
<script>
function viewOrder(storeId, merchantName) {
    window.location.href = 'orders.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId);
}
</script>
</body>
</html>
