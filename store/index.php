<?php
include_once("../header.php");

function displayStore()
{
    global $conn, $type;
    // Updated SQL query to join with the merchant table
    $sql = "SELECT store.*, merchant.merchant_name 
            FROM store 
            JOIN merchant ON store.merchant_id = merchant.merchant_id";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $shortStoreId = substr($row['store_id'], 0, 8);
            echo "<tr style='padding:15px 0;' data-uuid='" . $row['store_id'] . "'>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $shortStoreId . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['merchant_name'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['store_name'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['legal_entity_name'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;'>" . $row['store_address'] . "</td>";
            echo "<td style='text-align:center;display:none;'>" . $row['merchant_id'] . "</td>";
            echo "<td style='text-align:center;vertical-align: middle;' class='actions-cell'>";
            $escapedStoreName = htmlspecialchars($row['store_name'], ENT_QUOTES, 'UTF-8');
            $escapedLegalEntityName = htmlspecialchars($row['legal_entity_name'], ENT_QUOTES, 'UTF-8');
            $escapedStoreAddress = htmlspecialchars($row['store_address'], ENT_QUOTES, 'UTF-8');

            echo "<button class='btn' style='border:none;background-color:#4BB0B8;border-radius:20px;padding:0 10px;' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#fff;'></i></button>";

            echo "<div class='mt-2 actions-list' style='display:none;cursor:pointer;'>"; // Hidden initially
            echo "<ul class='list-group'>";

            if ($type !== 'User') {
                echo "<li class='list-group-item action-item' style='animation-delay: 0.1s;'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View</a></li>";
                echo "<li class='list-group-item action-item' style='animation-delay: 0.2s;'><a href='#' onclick='editStore(\"" . $row['store_id'] . "\")' style='color:#E96529;'>Edit</a></li>";
            } else {
                echo "<li class='list-group-item action-item' style='animation-delay: 0.1s;'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View</a></li>";
            }

            echo "</ul>"; 
            echo "</div>"; 

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
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
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
      color: #E96529;
    }

    @keyframes fadeIn {
      from {
        opacity: 0;
        transform: translateY(-10px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .action-item {
      animation: fadeIn 0.3s ease forwards;
    }

    .add-btns {
      padding-bottom: 0px;
      padding-right: 5vh;
      display: flex;
      align-items: center;
    }

    .modal-title {
      font-size: 15px;
      font-weight: bold;
    }

    .form-label {
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
        text-align: left !important;
        font-weight: bold;
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
        content: "Merchant ID";
      }

      td:nth-of-type(2):before {
        content: "Merchant Name";
      }

      td:nth-of-type(3):before {
        content: "Merchant Type";
      }

      td:nth-of-type(4):before {
        content: "Legal Entity Name";
      }

      td:nth-of-type(5):before {
        content: "Fullfillment Type";
      }

      td:nth-of-type(6):before {
        content: "Business Address";
      }

      td:nth-of-type(7):before {
        content: "Email Address";
      }

      td:nth-of-type(8):before {
        content: "VAT Type";
      }

      td:nth-of-type(9):before {
        content: "Commission ID";
      }

      td:nth-of-type(10):before {
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

      .add-btns {
        padding-right: 2vh;
      }
    }
  </style>
</head>

<body>
  <div class="cont-box">
    <div class="custom-box pt-4">
      <div class="sub" style="text-align:left;">

        <div class="add-btns">
          <p class="title">Store</p>
          <a href="upload.php"><button type="button" class="btn btn-danger add-merchant"><i
                class="fa-solid fa-upload"></i> Upload Stores</button></a>
        </div>

        <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
          <table id="example" class="table bord" style="width:100%;">
            <thead>
              <tr>
                <th style="width:80px;">Store ID</th>
                <th style="width:140px;">Merchant Name</th>
                <th style="display:none;"></th>
                <th>Store Name</th>
                <th>Legal Entity Name</th>
                <th>Store Address</th>
                <th style="width:100px;">Actions</th>
          
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayStore(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Edit Modal -->
    <div class="modal fade" id="editStoreModal" data-bs-backdrop="static" tabindex="-1"
        aria-labelledby="editStoreModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius:20px;">
                <div class="modal-header border-0">
                    <p class="modal-title" id="editStoreModalLabel">Edit Store Details</p>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editStoreForm" action="edit.php" method="POST">
                        <input type="hidden" id="storeId" name="storeId">
                        <input type="hidden" id="merchantId" name="merchantId">
                        <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
                        <div class="mb-3">
                            <label for="storeName" class="form-label">Store Name</label>
                            <input type="text" class="form-control" id="storeName" name="storeName">
                        </div>
                        <div class="mb-3">
                            <label for="legalEntityName" class="form-label">Legal Entity Name</label>
                            <input type="text" class="form-control" id="legalEntityName" name="legalEntityName">
                        </div>
                        <div class="mb-3">
                            <label for="storeAddress" class="form-label">Store Address</label>
                            <input type="text" class="form-control" id="storeAddress" name="storeAddress">
                        </div>
                        <button type="submit" class="btn btn-primary"
                            style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Save
                            changes</button>
                    </form>
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
          scrollX: true,
          columnDefs: [
            { orderable: false, targets: [0, 4, 5] }    // Disable sorting for the specified columns
          ],
          order: []  // Ensure no initial ordering
        });
      });
    </script>
    <script>
      function editStore(storeId) {
            var storeRow = $('#dynamicTableBody').find('tr[data-uuid="' + storeId + '"]');
            var storeName = storeRow.find('td:nth-child(3)').text();
            var legalEntityName = storeRow.find('td:nth-child(4)').text();
            var storeAddress = storeRow.find('td:nth-child(5)').text();
            var merchantId = storeRow.find('td:nth-child(6)').text();


            // Set values in the edit modal
            $('#storeId').val(storeId);
            $('#storeName').val(storeName);
            $('#storeAddress').val(storeAddress);
            $('#legalEntityName').val(legalEntityName);
            $('#merchantId').val(merchantId);

            // Open the edit modal
            $('#editStoreModal').modal('show');
        }

        function viewOrder(storeId, storeName) {
            window.location.href = 'order/index.php?store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
        }
    </script>
    <script>
    function toggleActions(button) {
        // Find the actions-list div relative to the button
        var actionsList = button.nextElementSibling;

        // Toggle the display style of the actions-list div
        if (actionsList.style.display === 'none' || actionsList.style.display === '') {
            actionsList.style.display = 'block';
        } else {
            actionsList.style.display = 'none';
        }
    }
</script>
</body>

</html>
