<?php require_once("../header.php")?>
<?php
function displayUser() {
  include("../inc/config.php");

  $sql = "SELECT * FROM user";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
      $count = 1;
      while ($row = $result->fetch_assoc()) {
          $shortUserId = substr($row['user_id'], 0, 8);
          $checked = $row['status'] == 'Active' ? 'checked' : '';
          echo "<tr data-id='" . $row['user_id'] . "'>";
          echo "<td style='text-align:center;vertical-align: middle;'>" . $shortUserId . "</td>";
          echo "<td style='text-align:center;vertical-align: middle;'>" . $row['name'] . "</td>";
          echo "<td style='text-align:center;vertical-align: middle;'>" . $row['email_address'] . "</td>";
          echo "<td style='text-align:center;vertical-align: middle;'>" . $row['type'] . "</td>";
          echo "<td style='text-align:center;vertical-align: middle;'>" . $row['department'] . "</td>";
          echo "<td style='text-align:center;vertical-align: middle;'>" . $row['status'] . "</td>";
          echo "<td style='text-align:center;vertical-align: middle;'>";
          echo "<div class='form-check form-switch form-switch-lg' style='display: flex; justify-content: center; accent-color: red;'>";
          echo "<input class='form-check-input' type='checkbox' role='switch' id='flexSwitchCheckChecked' $checked>";
          echo "</div>";
          echo "</td>";
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
<title>Homepage</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
<link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
<script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
<link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
<link rel='stylesheet' href='https://cdn.datatables.net/fixedcolumns/3.3.3/css/fixedColumns.bootstrap5.min.css'>
<script src='https://cdn.datatables.net/fixedcolumns/3.3.3/js/dataTables.fixedColumns.min.js'></script>
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

    .title{
      font-size: 30px; 
      font-weight: 900; 
      margin-right: auto; 
      padding-left: 5vh;
      color: #E96529;
    }
    
    .form-switch.form-switch-lg .form-check-input {
  height: 2rem;
  width: calc(3rem + 0.75rem);
  border-radius: 4rem;
}

.form-check-input:checked {
    background-color: #28a745; /* Change this color to your desired checked color */
    border-color: #28a745; /* Change this color to your desired checked color */
  }
    .add-btns{
      padding-bottom: 0px; 
      padding-right: 5vh; 
      display: flex; 
      align-items: center;
    }
</style>
</head>
<body>
  <div class="cont-box">
    <div class="custom-box pt-4">
      <div class="sub" style="text-align:left;">
        <div class="add-btns">
          <p class="title"> <i class="fa-solid fa-user-gear fa-sm"></i> Manage Users</p>
          <a href="add_account.php"><button type="button" class="btn add-merchant"><i class="fa-solid fa-user-plus"></i> Create Account</button></a>
        </div>
        <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
          <div class="table-container">
            <table id="example" class="table bord" style="width:100%;">
              <thead>
                <tr>
                  <th>User ID</th>
                  <th>Name</th>
                  <th>Email Address</th>
                  <th>Type</th>
                  <th>Department</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody id="dynamicTableBody">
                <?php displayUser(); ?>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal -->
  <div class="modal fade" id="statusModal" tabindex="-1" aria-labelledby="statusModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content" style="backdrop-filter: blur(16px) saturate(180%);-webkit-backdrop-filter: blur(16px) saturate(180%);background-color: rgba(255, 255, 255, 0.40);border-radius: 12px;border: 1px solid rgba(209, 213, 219, 0.3);">
   
        <div class="modal-body text-center pt-5 pb-5" id="modalBody">
          <!-- Content will be inserted by JavaScript -->
        </div>
        <div class="modal-footer text-center">
                <button type="button" class="btn" data-bs-dismiss="modal" style="background-color:transparent;margin: 0 auto;">Cancel</button>
                <button type="button" class="btn" id="confirmButton" style="background-color:transparent;margin: 0 auto;color: red;">Yes</button>
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
      if ( $.fn.DataTable.isDataTable('#example') ) {
        $('#example').DataTable().destroy();
      }

      $('#example').DataTable({
        scrollX: true
      });

      let selectedUserId;
      let newStatus;
      let originalChecked;

      $('.form-check-input').on('change', function() {
        selectedUserId = $(this).closest('tr').data('id');
        newStatus = this.checked ? 'active' : 'inactive';
        originalChecked = this.checked;
        $('#modalBody').text(`Are you sure you want to make this user ${newStatus}?`);
        $('#statusModal').modal('show');
      });

      $('#confirmButton').on('click', function() {
        $('#statusModal').modal('hide');
        changeStatus(selectedUserId, newStatus, originalChecked);
      });

      $('#statusModal').on('hidden.bs.modal', function () {
        if ($('#confirmButton').data('confirmed') !== true) {
          $('.form-check-input').each(function() {
            if ($(this).closest('tr').data('id') === selectedUserId) {
              $(this).prop('checked', !originalChecked);
            }
          });
        }
        $('#confirmButton').data('confirmed', false);
      });

      function changeStatus(userId, status, originalChecked) {
        // Make an AJAX call to update the status in the database
        $.ajax({
          type: 'POST',
          url: 'update_status.php', // Create a PHP file to handle the status update
          data: { userId: userId, status: status },
          success: function(response) {
            $('#confirmButton').data('confirmed', true);
            $(`tr[data-id='${userId}'] td:nth-child(6)`).text(status.charAt(0).toUpperCase() + status.slice(1));
          },
          error: function(xhr, status, error) {
            console.error('Error updating status: ' + error);
            $('.form-check-input').each(function() {
              if ($(this).closest('tr').data('id') === userId) {
                $(this).prop('checked', !originalChecked);
              }
            });
          }
        });
      }
    });
  </script>
</body>
</html>

