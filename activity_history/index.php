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
  <link rel="stylesheet" href="../responsive-table-styles/activity_history.css">
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
            { orderable: false, targets: [0, 1, 2, 3, 4, 5, 6, 7] } 
          ],
        order: [[6, 'desc']]
      });

      $('#example tbody').on('click', 'td:nth-child(1), td:nth-child(2), td:nth-child(3), td:nth-child(4), td:nth-child(5), td:nth-child(6), td:nth-child(7), td:nth-child(8)', function () {
        var row = $(this).closest('tr');
        var activityId = row.data('id');
    
        $.ajax({
          url: 'get_activity_history_details.php', 
          method: 'POST',
          data: { activityId: activityId },
          success: function (response) {
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