<?php
include_once ("../header.php");

function displayStore()
{
  global $conn, $type;
  // Updated SQL query to join with the merchant table
  $sql = "SELECT * FROM store_view";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $shortStoreId = substr($row['store_id'], 0, 8);
      
      // Prepare truncated and full text for email_address
      $email_address_full = empty($row['email_address']) ? '-' : $row['email_address'];
      $email_address = strlen($row['email_address']) > 30 ? substr($row['email_address'], 0, 30) . '...' : $row['email_address'];

      echo "<tr style='padding:15px 0;' data-uuid='" . $row['store_id'] . "'>";
      echo "<td>" . $shortStoreId . "</td>";
      echo "<td>" . $row['store_name'] . "</td>";
      echo "<td style='display:none;'>" . $row['merchant_id'] . "</td>";
      echo "<td>" . $row['merchant_name'] . "</td>";
      echo "<td>" . $row['legal_entity_name'] . "</td>";
      echo "<td>" . $row['store_address'] . "</td>";
      echo "<td style='display:none;'>" . htmlspecialchars($email_address_full) . "</td>";
      echo "<td class='text-cell' data-full='" . htmlentities($email_address_full) . "' data-short='" . htmlentities($email_address) . "'>" . $email_address . "</td>";      
      echo "<td class='actions-cell'>";
      echo "<button class='btn action-btn' onclick='toggleActions(this)'><i class='fa-solid fa-ellipsis' style='font-size:25px;color:#F1F1F1;'></i></button>";
      echo "<div class='mt-2 actions-list' style='display:none;cursor:pointer;'>"; // Hidden initially
      echo "<ul class='list-group'>";

      $escapedStoreName = htmlspecialchars($row['store_name'], ENT_QUOTES, 'UTF-8');
      $escapedLegalEntityName = htmlspecialchars($row['legal_entity_name'], ENT_QUOTES, 'UTF-8');
      $escapedStoreAddress = empty($row['store_address']) ? '-' : htmlspecialchars($row['store_address'], ENT_QUOTES, 'UTF-8');

      if ($type !== 'User') {
        echo "<li class='list-group-item action-item'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View</a></li>";
        echo "<li class='list-group-item action-item'><a href='#' onclick='editStore(\"" . $row['store_id'] . "\")' style='color:#E96529;'>Edit</a></li>";
      } else {
        echo "<li class='list-group-item action-item'><a href='#' onclick='viewOrder(\"" . $row['store_id'] . "\", \"" . $escapedStoreName . "\")' style='color:#E96529;'>View</a></li>";
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
  <title>Stores</title>
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

      td:nth-of-type(1):before {
        content: "Store ID";
      }

      td:nth-of-type(2):before {
        content: "Store Name";
      }

      td:nth-of-type(3):before {
        content: "Merchant Name";
      }

      td:nth-of-type(4):before {
        content: "Legal Entity Name";
      }

      td:nth-of-type(5):before {
        content: "Store Address";
      }

      td:nth-of-type(6):before {
        content: "Email Address";
      }

      td:nth-of-type(7):before {
        content: "Actions";
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
          <p class="title">Stores</p>
          <a href="upload.php">
            <button type="button" class="btn btn-primary add-merchant">
              <i class="fa-solid fa-upload"></i> Upload Stores
            </button>
          </a>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:100%;">
            <thead>
              <tr>
                <th class="first-col" style="width:7%">Store ID</th>
                <th style="width:20%">Store Name</th>
                <th style="display:none;"></th>
                <th style="width:15%">Merchant Name</th>
                <th>Legal Entity Name</th>
                <th>Store Address</th>
                <th style="display:none;"></th>
                <th>Email Address</th>
                <th class="action-col" style="width:8%">Actions</th>
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
                <label for="storeName" class="form-label">
                  Store Name<span class="text-danger" style="padding:2px">*</span>
                </label>
                <input type="text" class="form-control" id="storeName" name="storeName"
                  placeholder="Enter store name" required maxlength="255">
              </div>
              <div class="mb-3">
                <label for="merchantName" class="form-label">
                  Merchant Name<span class="text-danger" style="padding:2px">*</span>
                </label>
                <input type="text" class="form-control" id="merchantName" name="merchantName"
                  style="background-color: #d3d3d3; caret-color: transparent;"
                  placeholder="Enter merchant name" required readonly>
              </div>
              <div class="mb-3">
                <label for="legalEntityName" class="form-label">Legal Entity Name</label>
                <input type="text" class="form-control" id="legalEntityName" name="legalEntityName"
                  placeholder="Enter legal entity name" maxlength="255">
              </div>
              <div class="mb-3">
                <label for="storeAddress" class="form-label">Store Address</label>
                <textarea type="text" class="form-control" id="storeAddress" name="storeAddress"
                  placeholder="Enter store address" rows="2"></textarea>
              </div>
              <div class="mb-3">
                <label for="emailAddress" class="form-label">Email Address</label>
                <textarea type="text" class="form-control" id="emailAddress" name="emailAddress"
                  placeholder="Enter email address" rows="2"></textarea>
              </div>
              <button type="submit" class="btn btn-primary modal-save-btn">Save changes</button>
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
            { orderable: false, targets: [0, 5, 6, 7, 8] }    // Disable sorting for the specified columns
          ],
          order: [[1, 'asc']]
        });
      });
    </script>
    <script>
      function editStore(storeId) {
        var storeRow = $('#dynamicTableBody').find('tr[data-uuid="' + storeId + '"]');
        var storeName = storeRow.find('td:nth-child(2)').text();
        var merchantId = storeRow.find('td:nth-child(3)').text();
        var merchantName = storeRow.find('td:nth-child(4)').text();
        var legalEntityName = storeRow.find('td:nth-child(5)').text();
        var storeAddress = storeRow.find('td:nth-child(6)').text();
        var emailAddress = storeRow.find('td:nth-child(7)').text();        

        // Set values in the edit modal
        $('#storeId').val(storeId);
        $('#storeName').val(storeName);
        $('#merchantId').val(merchantId);
        $('#merchantName').val(merchantName);
        
        if (legalEntityName === '-') {
            $('#legalEntityName').val(null);
        } else {
            $('#legalEntityName').val(legalEntityName);
        }

        if (storeAddress === '-') {
            $('#storeAddress').val(null);
        } else {
            $('#storeAddress').val(storeAddress);
        }

        if (emailAddress === '-') {
            $('#emailAddress').val(null);
        } else {
            $('#emailAddress').val(emailAddress);
        }

        // Open the edit modal
        $('#editStoreModal').modal('show');
      }

      function viewOrder(storeId, storeName) {
        window.location.href = 'order/index.php?store_id=' + encodeURIComponent(storeId) + '&store_name=' + encodeURIComponent(storeName);
      }
    </script>

    <script>
      // Event delegation for text toggle of email address
      document.body.addEventListener('click', function (event) {
          if (event.target.classList.contains('text-cell')) {
            var fullText = event.target.getAttribute('data-full');
            var shortText = event.target.getAttribute('data-short');
            if (event.target.innerText === shortText) {
              event.target.innerText = fullText;
            } else {
              event.target.innerText = shortText;
            }
          }
        });
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