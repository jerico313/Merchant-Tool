<?php include("../header.php")?>
<?php
$fee_id = isset($_GET['fee_id']) ? $_GET['fee_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';

function displayFeeHistory($fee_id) {
    global $conn, $type;

    $sql = "SELECT fh.*, u.name AS changed_by_name
            FROM fee_history AS fh
            LEFT JOIN user AS u ON fh.changed_by = u.user_id
            WHERE fh.fee_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $fee_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortFeeId = substr($row['fee_history_id'], 0, 8);
            echo "<tr>";
            echo "<td style='text-align:center;'>" . $shortFeeId . "</td>";
            echo "<td style='text-align:center;'>" . $row['column_name'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['old_value'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['new_value'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['changed_at'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['changed_by_name'] . "</td>"; 
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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
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
   <div class="lds-default"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>
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
                            <li class="breadcrumb-item"><a href="index.php" style="color:#E96529; font-size:14px;">Fees</a></li>
                            <li class="breadcrumb-item"><a href="#" onclick="location.reload();" style="color:#E96529; font-size:14px;">History</a></li>
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
                            <th class="first-col">Fee History ID</th>
                            <th>Column Name</th>
                            <th>Old Value</th>
                            <th>New Value</th>
                            <th>Change At</th>
                            <th class="action-col">Changed By</th>
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
$(window).on('load', function() {
   $('.loading').hide();
   $('.cont-box').show();

   var table = $('#example').DataTable({
      scrollX: true,
      order: [[4, 'desc']],
        createdRow: function (row, data, dataIndex) {
            var date = new Date(data[4]);
            var formattedDate = date.toLocaleString('en-US', { year: 'numeric', month: 'long', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
            $('td:eq(4)', row).html(formattedDate); 
        }
   }); 
});
</script>
</body>
</html>
