<?php include("../../../header.php")?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';

function displayOffers($store_id) {
    include("../../../inc/config.php");

    $sql = "SELECT * FROM transaction_summary_view WHERE `Store ID` = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $store_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortStoreId = substr($row['Store ID'], 0, 8);
            $shortMerchantId = substr($row['Merchant ID'], 0, 8);
            $shortPromoId = substr($row['Promo ID'], 0, 8);
            echo "<tr>";
            echo "<td style='text-align:center;'>" . $row['Transaction ID']. "</td>";
            echo "<td style='text-align:center;'>" . $row['Transaction Date'] . "</td>";
            echo "<td style='text-align:center;'>" . $shortMerchantId . "</td>";
            echo "<td style='text-align:center;'>" . $row['Merchant Name'] . "</td>";
            echo "<td style='text-align:center;'>" . $shortStoreId . "</td>";
            echo "<td style='text-align:center;'>" . $row['Store Name'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Customer ID'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Customer Name'] . "</td>";
            echo "<td style='text-align:center;'>" . $shortPromoId . "</td>";
            echo "<td style='text-align:center;'>" . $row['Promo Code'] . "</td>";       
            echo "<td style='text-align:center;'>" . $row['Promo Fulfillment Type'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Promo Group'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Promo Type'] . "</td>";     
            echo "<td style='text-align:center;'>" . $row['Gross Amount'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Discount'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Net Amount'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Payment'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Bill Status'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Commission Type'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Commission Rate'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Commission Amount'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Total Billing'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['PG Fee Rate'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['PG Fee Amount'] . "</td>";
            echo "<td style='text-align:center;'>" . $row['Amount to be Disbursed'] . "</td>";
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
                <button type="button" class="btn btn-warning check-report mt-4" id="btnCoupled">Coupled</button>
                <button type="button" class="btn btn-warning add-merchant mt-4" id="btnDecoupled">Decoupled</button>
                <button type="button" class="btn gcash mt-4" id="btnGCash"><img src="../../../images/gcash.png" style="width:25px; height:20px; margin-right: 1.80vw;" alt="gcash"><span>GCash</span></button>
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
                <button type="button" onclick="downloadTables()" class="btn btn-warning download-csv mt-4"><i class="fa-solid fa-download"></i> Download CSV</button>
            </div>
            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <table id="example" class="table bord" style="width:280%;">
                    <thead>
                        <tr>
                            <th>Transaction ID</th>
                            <th>Transaction Date</th>
                            <th>Merchant ID</th>
                            <th>Merchant Name</th>
                            <th>Store ID</th>
                            <th>Store Name</th>
                            <th>Customer ID</th>
                            <th>Customer Name</th>
                            <th>Promo ID</th>
                            <th>Promo Code</th>
                            <th>Promo Fulfillment Type</th>
                            <th>Promo Group</th>
                            <th>Promo Type</th>           
                            <th>Gross Amount</th>
                            <th>Discount</th>
                            <th>Net Amount</th>
                            <th>Payment</th>
                            <th>Bill Status</th>
                            <th>Commission Type</th>
                            <th>Commission Rate</th>
                            <th>Commission Amount</th>
                            <th>Total Billing</th>
                            <th>PG Fee Rate</th>
                            <th>PG Fee Amount</th>
                            <th style="width:80px;">Amount to be Disbursed</th>
                        </tr>
                    </thead>
                    <tbody id="dynamicTableBody">
                    <?php displayOffers($store_id); ?>
                    </tbody>
                    <tfoot>
                        <tr id="noDataMessage" style="display: none;">
                            <td colspan="24" class="pl-5" style="margin-left:20px;">No data available in table</td>
                        </tr>
                    </tfoot>
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
function downloadTables() {
    // Get current date and format it for the file name
    const currentDate = new Date();
    const formattedDate = currentDate.toLocaleDateString().replace(/\//g, "-"); // Format date for file name

    // Assuming you have initialized DataTable on #example
    const tableData = $('#example').DataTable().rows().data().toArray();

    // Function to format customer ID if needed
    function formatDataForCSV(row) {
        return [
            row[0], row[1], row[2], row[3], row[4], row[5], 
            `'${row[6]}`, row[7], row[8], row[9], row[10], 
            row[11], row[12], row[13], row[14], row[15], 
            row[16], row[17], row[18], row[19], row[20], 
            row[21], row[22], row[23], row[24]
        ];
    }

    // Extracting all columns data and formatting customer ID
    const filteredData = tableData.map(row => formatDataForCSV(row));

    // Add headers for CSV file
    filteredData.unshift([
        'Transaction ID', 'Transaction Date', 'Merchant ID', 'Merchant Name', 'Store ID', 'Store Name',
        'Customer ID', 'Customer Name', 'Promo ID', 'Promo Code', 'Promo Fullfillment Type','Promo Group', 'Promo Type',
        'Gross Amount', 'Discount', 'Amount Discounted', 'Payment', 'Bill Status', 'Commission Type', 'Commission Rate',
        'Commission Amount', 'Total Billing', 'PG Fee Rate', 'PG Fee Amount', 'Amount to be Disbursed'
    ]);

    const csvContent = "data:text/csv;charset=utf-8," + filteredData.map(row => row.join(",")).join("\n");
    const encodedUri = encodeURI(csvContent);

    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `transaction_${formattedDate}.csv`);
    document.body.appendChild(link);

    link.click(); // Trigger the download
    document.body.removeChild(link);
}
</script>

<script>
$(document).ready(function() {
    // Initialize DataTable
    var table = $('#example').DataTable({
        scrollX: true, // Enable horizontal scrolling
        language: {
            emptyTable: "No data available in table"
        }
    });

    // Datepicker initialization
    $("#startDate").datepicker({
        dateFormat: "yy-mm-dd"
    });
    $("#endDate").datepicker({
        dateFormat: "yy-mm-dd"
    });

    // Function to filter rows based on promo type
    function filterRows(promoType) {
        table.rows().every(function() {
            var row = this.data();
            if (row[10] === promoType) { // Column index 11 is Promo Type
                $(this.node()).show();
            } else {
                $(this.node()).hide();
            }
        });

        // Show "No data available" message if all rows are hidden
        if (table.rows(':visible').count() === 0) {
            $('#noDataMessage').show();
        } else {
            $('#noDataMessage').hide();
        }
    }

    // Event handlers for filter buttons
    $('#btnCoupled').on('click', function() {
        filterRows('Coupled');
    });

    $('#btnDecoupled').on('click', function() {
        filterRows('Decoupled');
    });

    $('#btnGCash').on('click', function() {
        filterRows('GCash');
    });

    // Attach the download function to the button
    $('.download-csv').on('click', function() {
        downloadTables();
    });

    // Initially hide the message
    $('#noDataMessage').hide();
});

</script>
</body>
</html>
