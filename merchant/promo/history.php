<?php include ("../../header.php") ?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$promo_code = isset($_GET['promo_code']) ? $_GET['promo_code'] : '';
$changed_at = isset($_GET['changed_at']) ? $_GET['changed_at'] : '';
$changed_by = isset($_GET['changed_by']) ? $_GET['changed_by'] : '';

function displayOfferHistory($promo_code, $merchant_name)
{
    include ("../../inc/config.php");

    $sql = "SELECT * FROM promo_history WHERE promo_code = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $promo_code); // Corrected variable name
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortPromoHistoryId = substr($row['promo_history_id'], 0, 8);
            echo "<tr>";
            echo "<td style='text-align:center;'>" . $shortPromoHistoryId . "</td>";
            echo "<td style='text-align:center;'>" . $row['old_bill_status'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['new_bill_status'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['changed_at'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['changed_by'] . "</td>";
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
                content: "Promo Code";
            }

            td:nth-of-type(2):before {
                content: "Old Bill Status";
            }

            td:nth-of-type(3):before {
                content: "New Bill Status";
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
                                                href="index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers" style="color:#4BB0B8;">Promos</a>
                                        </li>
                                        <li><a class="dropdown-item"
                                                href="../reports/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Settlement Reports</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="breadcrumb-item"><a href="#" onclick="location.reload();"
                                        style="color:#E96529; font-size:14px;">History</a></li>
                            </ol>
                        </nav>
                        <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);">
                            <?php echo htmlspecialchars($promo_code); ?></p>
                    </div>
                </div>
                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:100%;">
                        <thead>
                            <tr>
                                <th>Promo History ID</th>
                                <th>Old Bill Status</th>
                                <th>New Bill Status</th>
                                <th>Changed At</th>
                                <th>Changed By</th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayOfferHistory($promo_code, $merchant_name); ?>
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
        $(document).ready(function () {
            if ($.fn.DataTable.isDataTable('#example')) {
                $('#example').DataTable().destroy();
            }

            $('#example').DataTable({
                scrollX: true
            });
        });
    </script>
</body>

</html>