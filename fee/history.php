<?php include("../header.php")?>
<?php
$fee_id = isset($_GET['fee_id']) ? $_GET['fee_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
function displayFeeHistory($fee_id) {
    include("../inc/config.php");

    $sql = "SELECT * FROM fee_history WHERE fee_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $fee_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortFeeId = substr($row['fee_history_id'], 0, 8);
            $date = new DateTime($row['changed_at']);
            $formattedDate = $date->format('F d, Y');
            echo "<tr>";
            echo "<td style='text-align:center;'>" .$shortFeeId . "</td>";
            echo "<td style='text-align:center;'>" .$row['column_name'] . "</td>";
            echo "<td style='text-align:center;'>" .$row['old_value'] . "</td>";
            echo "<td style='text-align:center;'>" .$row['new_value'] . "</td>";
            echo "<td style='text-align:center;'>" .$formattedDate . "</td>";
            echo "<td style='text-align:center;'>" .$row['changed_by'] . "</td>";
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
    <link rel="stylesheet" href="../style.css">
    <style>
        body {
            background-image: url("../images/bg_booky.png");
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
                content: "Promo ID";
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
                            <li class="breadcrumb-item"><a href="index.php" style="color:#E96529; font-size:14px;">Fee</a></li>
                            <li class="breadcrumb-item"><a href="#" onclick="location.reload();" style="color:#E96529; font-size:14px;">History</a></li>
                        </ol>
                    </nav>
                    <p class="title_store" style="font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);"><?php echo htmlspecialchars($merchant_name); ?></p>
                </div>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:100%;">
                    <thead>
                        <tr>
                            <th>Fee History ID</th>
                            <th>Column Name</th>
                            <th>Old Value</th>
                            <th>New Value</th>
                            <th>Change At</th>
                            <th>Change By</th>
                        </tr>
                    </thead>
                    <tbody id="dynamicTableBody">
                    <?php displayFeeHistory($fee_id); ?>
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
        scrollX: true,
        order: [[4, 'desc']] // Default sort by the 'Created At' column in descending order
    });
});
</script>
</body>
</html>
