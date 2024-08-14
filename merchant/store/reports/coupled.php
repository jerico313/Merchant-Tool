<?php include ("../../../header.php") ?>
<?php
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';

function displayDecoupled($store_id, $store_name)
{
    include ("../../../inc/config.php");

    $sql = "SELECT * FROM report_history_coupled WHERE store_id = ? ORDER BY created_at DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $store_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $date = new DateTime($row['created_at']);
            $formattedDate = $date->format('F d, Y g:i:s A');
            echo "<tr class='clickable-row' data-href='coupled_settlement_report.php?coupled_report_id=" . $row['coupled_report_id'] . "&store_id=" . $store_id . "&store_name=" . urlencode($store_name) . "&settlement_period_start=" . urlencode($row['settlement_period_start']) . "&settlement_period_end=" . urlencode($row['settlement_period_end']) . "&bill_status=" . urlencode($row['bill_status']) .  "'>";
            echo "<td style='text-align:center;'>" . $row['settlement_number'] . "</td>";
            echo "<td style='text-align:center;'><i class='fa-solid fa-file-pdf' style='color:#4BB0B8'></i> " . $row['store_brand_name'] . "_" . $row['settlement_number'] . ".pdf</td>";
            echo "<td style='text-align:center;'>" . $formattedDate . "</td>";
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
    <title><?php echo htmlspecialchars($store_name); ?> - Decoupled Settlement Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
            font-weight: 900;
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

        tr:hover {
            background-color: #e0e0e0 !important;
            color: white !important;
            cursor: pointer;
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
                                <li class="breadcrumb-item">
                                    <a href="../../../merchant/index.php" style="color:#E96529; font-size:14px;">
                                        Merchants
                                    </a>
                                </li>
                                <li class="breadcrumb-item dropdown">
                                    <a href="#" class="dropdown-toggle" role="button" id="storeDropdown"
                                        data-bs-toggle="dropdown" aria-expanded="false"
                                        style="color:#E96529;font-size:14px;">
                                        Stores
                                    </a>
                                    <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                                        <li><a class="dropdown-item"
                                                href="../../store/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers" style="color:#4BB0B8;"> Stores</a>
                                        </li>
                                        <li><a class="dropdown-item"
                                                href="../../promo/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                                data-breadcrumb="Offers">Promos</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="breadcrumb-item">
                                    <a href="index.php?store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>&merchant_id=<?php echo htmlspecialchars($merchant_id); ?>"
                                        style="color:#E96529; font-size:14px;">
                                        Settlement Reports
                                    </a>
                                </li>
                                <li class="breadcrumb-item">
                                    <a href="#" style="color:#E96529; font-size:14px;">
                                        Coupled
                                    </a>
                                </li>
                            </ol>
                        </nav>
                        <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);">
                            <?php echo htmlspecialchars($store_name, ENT_QUOTES, 'UTF-8'); ?>
                        </p>
                    </div>
                </div>
                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:100%;">
                        <thead>
                        <tr>
                                <th style="border-top-left-radius:10px;border-bottom-left-radius:10px;">
                                    Settlement Number</th>
                                <th>Filename</th>
                                <th style="border-top-right-radius:10px;border-bottom-right-radius:10px;">
                                    Created At</th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayDecoupled($store_id, $store_name); ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
    <script>
         $(window).on('load', function () {
        $('.loading').hide();
        $('.cont-box').show();

        var table = $('#example').DataTable({
          scrollX: true,
          columnDefs: [
            { orderable: false, targets: [0] }
          ],
          order: [[2, 'desc']],
        createdRow: function (row, data, dataIndex) {
            var date = new Date(data[2]); 
            var formattedDate = date.toLocaleString('en-US', { year: 'numeric', month: 'long', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
            $('td:eq(2)', row).html(formattedDate);
        }
   }); 

            $('#example tbody').on('click', 'tr', function () {
                var href = $(this).attr('data-href');
                if (href) {
                    window.location = href;
                }
            });
        });
    </script>
</body>

</html>