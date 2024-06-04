<?php include("../../header.php")?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

function displayOffers($merchant_id, $merchant_name) {
    include("../../inc/config.php");

    $sql = "SELECT * FROM offer WHERE merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $escapedMerchantName = htmlspecialchars($merchant_name, ENT_QUOTES, 'UTF-8');
            echo "<tr>";
            echo "<td style='text-align:center;'>" . $row['offer_id'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['offer_name'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['offer_details'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['offer_details'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['promo_code'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['promo_type'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['vat_type'] . "</td>";
            echo "<td style='text-align:center;'>";
            echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:80px;background-color:#E8C0AE;color:black;' onclick='viewHistory(\"" . $row['offer_id'] . "\", \"" . $escapedMerchantName . "\", \"" . $row['offer_id'] . "\")'>View History</button> ";
            echo "<button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#95DD59;color:black;' onclick='editMerchant(\"" . $row['offer_id'] . "\")'>Renew</button> ";
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
                            <li class="breadcrumb-item"><a href="../index.php" style="color:#E96529; font-size:14px;">Merchant</a></li>
                            <li class="breadcrumb-item dropdown">
                                <a href="#" class="dropdown-toggle" role="button" id="storeDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="color:#E96529;font-size:14px;">
                                Promo
                                </a>
                                <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                    <li><a class="dropdown-item" href="../store/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" data-breadcrumb="Offers">Store</a></li>
                                    <li><a class="dropdown-item" href="../category/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" data-breadcrumb="Category">Category</a></li>
                                </ul>
                            </li>
                        </ol>
                    </nav>
                    <p class="title_store" style="font-size:40px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);"><?php echo htmlspecialchars($merchant_name); ?></p>
                </div>
                <button type="button" class="btn btn-warning add-merchant mt-4"><i class="fa-solid fa-plus"></i> Add Promo</button>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:120%;">
                    <thead>
                        <tr>
                            <th>Promo ID</th>
                            <th>Offer Name</th>
                            <th>Offer Details</th>
                            <th>Offer Details</th>
                            <th>Promo Code</th>
                            <th>Promo Type</th>
                            <th>VAT Type</th>
                            <th style='width:200px;'>Action</th>
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
<script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
<script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
<script src="./js/script.js"></script>
<script>
$(document).ready(function() {
    if ($.fn.DataTable.isDataTable('#example')) {
        $('#example').DataTable().destroy();
    }
    
    $('#example').DataTable({
        scrollX: true
    });
});

function viewHistory(storeId, merchantName, offerId) {
    window.location.href = 'history.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=' + encodeURIComponent(merchantName) + '&store_id=' + encodeURIComponent(storeId) + '&offer_id=' + encodeURIComponent(offerId);
}
</script>
</body>
</html>
