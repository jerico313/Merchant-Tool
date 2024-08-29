<?php include ("../../header.php") ?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

function displayCoupled($merchant_id, $merchant_name)
{
    include ("../../inc/config.php");

    $sql = "SELECT rhc.*, user.name AS generated_by_name 
            FROM report_history_coupled rhc
            LEFT JOIN user ON user.user_id = rhc.generated_by
            WHERE merchant_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $merchant_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $generatedBy = $row['generated_by_name'] ? $row['generated_by_name'] : '-';
            $escapedMerchantName = htmlspecialchars($merchant_name, ENT_QUOTES, 'UTF-8');
            $date = new DateTime($row['created_at']);
            $formattedDate = $date->format('F d, Y g:i A');
            echo "<tr class='clickable-row' data-href='coupled_settlement_report.php?coupled_report_id=" . $row['coupled_report_id'] . "&merchant_id=" . $merchant_id . "&merchant_name=" . urlencode($merchant_name) . "&settlement_period_start=" . urlencode($row['settlement_period_start']) . "&settlement_period_end=" . urlencode($row['settlement_period_end']) . "&bill_status=" . urlencode($row['bill_status']) . "'>";
            echo "<td style='text-align:left;padding-left:20px;width:55%'><i class='fa-solid fa-file-pdf' style='color:#4BB0B8'></i> " . $escapedMerchantName . " - " . $row['settlement_period'] . " -(" . $row['settlement_number'] . ") ". $row['bill_status'] . ".pdf</td>";
            echo "<td style='width:25%'>" . $generatedBy . "</td>";
            echo "<td style='width:20%'>" . $formattedDate . "</td>";
            echo "</tr>";
        }
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
    <title><?php echo htmlspecialchars($merchant_name); ?> - Coupled Settlement Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="../../style.css">
    <style>
        body {
            background-image: url("../../images/bg_booky.png");
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
                                    <a href="../../merchants/index.php"
                                        style="color:#E96529; font-size:14px;">
                                        Merchants
                                    </a>
                                </li>
                                <li class="breadcrumb-item">
                                    <a href="index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                                        style="color:#E96529;font-size:14px;">
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
                        <p class="title2" style="padding-left:6px">
                            <?php echo htmlspecialchars($merchant_name, ENT_QUOTES, 'UTF-8'); ?>
                        </p>
                    </div>
                </div>
                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <table id="example" class="table bord" style="width:100%;">
                        <thead>
                            <tr>
                                <th class="first-col">File Name</th>
                                <th>Generated By</th>
                                <th class="action-col">Created At</th>
                            </tr>
                        </thead>
                        <tbody id="dynamicTableBody">
                            <?php displayCoupled($merchant_id, $merchant_name); ?>
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
            var formattedDate = date.toLocaleString('en-US', { year: 'numeric', month: 'long', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: true });
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