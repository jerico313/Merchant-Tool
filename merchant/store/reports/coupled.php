<?php include("../../../header.php") ?>
<?php
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';

function displayCoupled($store_id, $store_name) {
    include_once("../../../inc/config.php");

    $sql = "SELECT * FROM report_history_coupled WHERE store_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $store_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $escapedMerchantName = htmlspecialchars($store_name, ENT_QUOTES, 'UTF-8');
            $shortCoupledId = substr($row['coupled_report_id'], 0, 8);
            echo "<tr class='clickable-row' data-href='coupled_settlement_report.php?coupled_report_id=" . $row['coupled_report_id'] . "&store_id=" . $store_id . "&store_name=" . urlencode($store_name) . "'>";
            echo "<td style='text-align:center;'>" . $shortCoupledId . "</td>";
            echo "<td style='text-align:center;'><i class='fa-solid fa-file' style='color:#4BB0B8'></i> " . $row['store_business_name']."_". $row['settlement_number']. ".pdf</td>";
            echo "<td style='text-align:center;'>" . $row['created_at'] . "</td>";
            echo "</tr>";
        }
    } else {
        echo "<tr><td colspan='3' style='text-align:center;'>No records found</td></tr>";
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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
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
<div class="cont-box">
    <div class="custom-box pt-4">
        <div class="sub" style="text-align:left;">
            <div class="voucher-type">
                <div class="row pb-2 title" aria-label="breadcrumb">
                <nav aria-label="breadcrumb">
                        <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                            <li class="breadcrumb-item"><a href="../../store/index.php?store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>" style="color:#E96529; font-size:14px;">Store</a></li>
                            <li class="breadcrumb-item"><a href="../settlement_reports.php?store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>" style="color:#E96529; font-size:14px;">Settlement Report</a></li>    
                            <li class="breadcrumb-item"><a href="#" style="color:#E96529; font-size:14px;">Coupled</a></li>                            
                        </ol>
                    </nav> 
                    <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);"><?php echo htmlspecialchars($store_name, ENT_QUOTES, 'UTF-8'); ?></p>
                </div>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:100%;">
                    <thead>
                        <tr>
                            <th>Coupled Report ID</th>
                            <th>Filename</th>
                            <th>Created At</th>
                        </tr>
                    </thead>
                    <tbody id="dynamicTableBody">
                        <?php displayCoupled($store_id, $store_name); ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
<script>
    $(document).ready(function () {
        $('#example').DataTable({
            scrollX: true
        });

        // Bind click event to all rows
        $('#example tbody').on('click', 'tr', function() {
            var href = $(this).attr('data-href');
            if (href) {
                window.location = href;
            }
        });
    });
</script>
</body>
</html>
