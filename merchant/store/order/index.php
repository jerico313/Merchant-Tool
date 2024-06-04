<?php include("../../../header.php")?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';

function displayOffers($merchant_id) {
    include("../../../inc/config.php");

    $sql = "SELECT * FROM transaction WHERE store_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td style='text-align:center;'>" . $row['transaction_id'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['store_id'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['offer_id'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['customer_id'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['customer_name'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['transaction_date'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['gross_sales'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['mode_of_payment'] . "</td>";
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
                            <li class="breadcrumb-item"><a href="../../index.php" style="color:#E96529; font-size:14px;">Merchant</a></li>
                            <li class="breadcrumb-item"><a href="../index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" style="color:#E96529; font-size:14px;">Store</a></li>
                            <li class="breadcrumb-item"><a href="#" onclick="location.reload();" style="color:#E96529; font-size:14px;">Transaction Details</a></li>
                        </ol>
                    </nav>
                    <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);"><?php echo htmlspecialchars($store_name); ?></p>
                </div>
                <button type="button" class="btn btn-warning check-report mt-4">Coupled</button>
                <button type="button" class="btn btn-warning add-merchant mt-4">Decoupled</button>
                <button type="button" class="btn gcash mt-4" style="background-color:#007DFE !important; border:solid 2px #007DFE !important; display: flex;"><img src="../../../images/gcash.png" style="width:25px; height:20px; margin-right: 1.80vw;" alt="gcash"><span>GCash</span></button>
                <div class="dropdown">
                    <button class="btn btn-primary dropdown-toggle mt-4" type="button" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-expanded="false" style="width:150px;margin-left:10px;border-radius:20px;height:32px;background-color: #E96529;border:solid #E96529 2px;">
                        Select Date Range
                    </button>
                    <div class="dropdown-menu p-4" aria-labelledby="dropdownMenuButton">
                        <form>
                            <div class="form-group">
                                <label for="startDate">Start Date</label>
                                <input type="text" class="form-control" id="startDate" placeholder="Select start date">
                            </div>
                            <div class="form-group mt-3">
                                <label for="endDate">End Date</label>
                                <input type="text" class="form-control" id="endDate" placeholder="Select end date">
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:110%;">
                    <thead>
                        <tr>
                            <th>Transaction ID</th>
                            <th>Store ID</th>
                            <th>Offer ID</th>
                            <th>Customer ID</th>
                            <th>Customer Name</th>
                            <th>Transaction Date</th>
                            <th>Gross Sale</th>
                            <th>Mode of Payment</th>
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

<script>
$(document).ready(function() {
    $('#example').DataTable({
        scrollX: true
    });

    $("#startDate").datepicker({
        dateFormat: "yy-mm-dd"
    });
    $("#endDate").datepicker({
        dateFormat: "yy-mm-dd"
    });
});
</script>
</body>
</html>
