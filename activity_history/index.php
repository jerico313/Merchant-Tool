<?php require_once ("../header.php") ?>
<?php
function displayHistory()
{
  global $conn, $type;

  $sql = "SELECT * FROM activity_history_view";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
    $count = 1;
    while ($row = $result->fetch_assoc()) {
      // Output for debugging
      echo "<!-- Debug: created_at=" . $row['created_at'] . " -->";

      echo "<tr data-id='" . $row['activity_history_id'] . "' class='message-row'>";
      echo "<td>" . $row['activity_history_id'] . "</td>";
      echo "<td>" . $row['table_name'] . "</td>";
      echo "<td>" . $row['table_id'] . "</td>";
      echo "<td style='width:20%;'>" . $row['column_name'] . "</td>";
      echo "<td>" . $row['activity_type'] . "</td>";
      echo "<td>" . $row['user_name'] . "</td>";
      echo "<td style='display:none;'>" . $row['created_at'] . "</td>";
      echo "<td>" . $row['time_ago'] . "</td>";
      echo "</tr>";
      $count++;
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
  <title>Activity History</title>
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

    .loading {
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 80vh;
      font-size: 18px;
      color: #333;
      font-weight: 800;
    }

    .cont-box {
      display: none;
    }


    .lds-default,
    .lds-default div {
      box-sizing: border-box;
    }

    .lds-default {
      display: inline-block;
      position: relative;
      width: 80px;
      height: 80px;
      color: #E96529;
    }

    .lds-default div {
      position: absolute;
      width: 6.4px;
      height: 6.4px;
      background: currentColor;
      border-radius: 50%;
      animation: lds-default 1.2s linear infinite;
    }

    .lds-default div:nth-child(1) {
      animation-delay: 0s;
      top: 36.8px;
      left: 66.24px;
    }

    .lds-default div:nth-child(2) {
      animation-delay: -0.1s;
      top: 22.08px;
      left: 62.29579px;
    }

    .lds-default div:nth-child(3) {
      animation-delay: -0.2s;
      top: 11.30421px;
      left: 51.52px;
    }

    .lds-default div:nth-child(4) {
      animation-delay: -0.3s;
      top: 7.36px;
      left: 36.8px;
    }

    .lds-default div:nth-child(5) {
      animation-delay: -0.4s;
      top: 11.30421px;
      left: 22.08px;
    }

    .lds-default div:nth-child(6) {
      animation-delay: -0.5s;
      top: 22.08px;
      left: 11.30421px;
    }

    .lds-default div:nth-child(7) {
      animation-delay: -0.6s;
      top: 36.8px;
      left: 7.36px;
    }

    .lds-default div:nth-child(8) {
      animation-delay: -0.7s;
      top: 51.52px;
      left: 11.30421px;
    }

    .lds-default div:nth-child(9) {
      animation-delay: -0.8s;
      top: 62.29579px;
      left: 22.08px;
    }

    .lds-default div:nth-child(10) {
      animation-delay: -0.9s;
      top: 66.24px;
      left: 36.8px;
    }

    .lds-default div:nth-child(11) {
      animation-delay: -1s;
      top: 62.29579px;
      left: 51.52px;
    }

    .lds-default div:nth-child(12) {
      animation-delay: -1.1s;
      top: 51.52px;
      left: 62.29579px;
    }

    @keyframes lds-default {

      0%,
      20%,
      80%,
      100% {
        transform: scale(1);
      }

      50% {
        transform: scale(1.5);
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
        <div class="add-btns">
          <p class="title"><i class="fa-solid fa-user-clock fa-sm"></i> Activity History</p>
        </div>
        <div class="content">
          <table id="example" class="table bord" style="width:100%;">
            <thead>
              <tr>
                <th class="first-col">Activity ID</th>
                <th>Table Name</th>
                <th>Table ID</th>
                <th>Key Identifier</th>
                <th>Activity Type</th>
                <th>Modified By</th>
                <th style="display:none;"></th>
                <th class="action-col">Updated At</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayHistory(); ?>

            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <div class="modal fade" id="messageModal" tabindex="-1" aria-labelledby="messageModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content" style="border-radius:20px;">
        <div class="modal-header">
          <p class="modal-title" id="messageModalLabel">Activity History Details</p>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <!-- Message content will be dynamically populated here -->
        </div>
      </div>
    </div>
  </div>
  <script src='https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js'></script>
  <script src='https://cdn.datatables.net/responsive/2.1.0/js/dataTables.responsive.min.js'></script>
  <script src='https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js'></script>
  <script src="./js/script.js"></script>
  <script>
    $(window).on('load', function () {
      $('.loading').hide();
      $('.cont-box').show();

      var table = $('#example').DataTable({
        scrollX: true,
        columnDefs: [
            { orderable: false, targets: [0, 1, 2, 3, 4, 5, 6, 7] }    // Disable sorting for the specified columns
          ],
        order: [[6, 'desc']]
      });

      // Add click event to specific columns (1, 2, 3, and 4)
      $('#example tbody').on('click', 'td:nth-child(1), td:nth-child(2), td:nth-child(3), td:nth-child(4), td:nth-child(5), td:nth-child(6), td:nth-child(7), td:nth-child(8)', function () {
        // Access the row from the clicked cell
        var row = $(this).closest('tr');
        var activityId = row.data('id');

        // Fetch subject, message, and date using AJAX
        $.ajax({
          url: 'get_activity_history_details.php', // Replace with the actual PHP file to fetch details
          method: 'POST',
          data: { activityId: activityId },
          success: function (response) {
            // Display the subject, message, and date in the modal
            $('#messageModal .modal-body').html(response);
            $('#messageModal').modal('show');
          },
          error: function (error) {
            console.log(error);
            alert('Error: ' + error.statusText);
          }
        });
      });
    });
  </script>
</body>

</html>