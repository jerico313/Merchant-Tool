<?php
include_once ("../header.php");

function displayUser()
{
  global $conn, $type;
  $sql = "SELECT * FROM user";
  $result = $conn->query($sql);

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $shortUsertId = substr($row['user_id'], 0, 8);

      echo "<tr data-uuid='" . $row['user_id'] . "'>";
      echo "<td style='text-align:center;vertical-align: middle;padding:13px 0;'>" . $shortUsertId . "</td>";
      echo "<td style='text-align:center;vertical-align: middle;'>" . $row['name'] . "</td>";
      echo "<td style='text-align:center;vertical-align: middle;'>" . $row['email_address'] . "</td>";
      echo "<td style='text-align:center;vertical-align: middle;'>" . $row['type'] . "</td>";
      echo "<td style='text-align:center;vertical-align: middle;'>" . $row['status'] . "</td>";
      echo "<td style='display:none;'>" . $row['password'] . "</td>";
      echo "<td style='text-align:center;vertical-align: middle;'>";
      echo "<button class='btn check-report' style='border-radius:20px;width:60px;' onclick='editUser(\"" . $row['user_id'] . "\")'>Edit</button> ";
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
  <title>Merchants</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js"
    integrity="sha384-oBqDVmMz4fnFO9gybB08pRA9KFNJ6i7rtCIL9W8IKOmG4CJoFtI03eZI7Ph9jGxi"
    crossorigin="anonymous"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"
    integrity="sha384-mQ93qBRaUHnTwhWm6A98qE6pK6DdEDQNl7h4WBC5h85ibG/NHOoxuHV9r+lpazjl"
    crossorigin="anonymous"></script>
  <link rel="stylesheet" href="../style.css">
  <link rel="stylesheet" href="../responsive-table-styles/users.css">
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
          <p class="title"><i class="fa-solid fa-user-gear fa-sm"></i> Manage Users</p>
          <a href="add_account.php"><button type="button" class="btn add-merchant"><i class="fa-solid fa-user-plus"></i> Add User</button></a>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:100%;height:auto;">
            <thead>
            <tr>
                  <th class="first-col">User ID</th>
                  <th>Name</th>
                  <th>Email Address</th>
                  <th>Type</th>
                  <th>Status</th>
                  <th style="display:none;"></th>
                  <th class="action-col">Action</th>
                </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayUser(); ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>

<div class="modal fade" id="editUserModal" data-bs-backdrop="static" tabindex="-1"
  aria-labelledby="editUserModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:20px;">
      <div class="modal-header border-0">
        <p class="modal-title" id="editUserModalLabel" style="color:#E96529;font-weight:900;font-size:15px;">
          <i class="fa-solid fa-user-pen"></i> Edit User Details
        </p>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        
        <form id="editUserForm" method="POST" action="edit.php">
          <input type="hidden" id="user_Id" name="user_Id">
          <input type="hidden" value="<?php echo htmlspecialchars($user_id); ?>" name="userId">
          <div class="mb-3">
            <label for="name" class="form-label">
              Name<span class="text-danger" style="padding:2px">*</span>
            </label>
            <input type="text" class="form-control" id="name" name="name" placeholder="Enter user name" required maxlength="255">
          </div>
          <div class="mb-3">
            <label for="emailAddress" class="form-label">
              Email address<span class="text-danger" style="padding:2px">*</span>
            </label>
            <input type="email" class="form-control" id="emailAddress" name="emailAddress" placeholder="Enter email address">
          </div>
          <div class="mb-3">
            <label for="type" class="form-label">Type<span class="text-danger" style="padding:2px">*</span></label>
            <select class="form-select" id="type" name="type">
              <option value="Admin">Admin</option>
              <option value="User">User</option>
            </select>
          </div>
          <div class="mb-3">
            <label for="status" class="form-label">Status<span class="text-danger" style="padding:2px">*</span></label>
            <select class="form-select" id="status" name="status">
              <option value="Active">Active</option>
              <option value="Inactive">Inactive</option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary modal-save-btn" id="saveChanges">Save changes</button>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
  function showAlert(message) {
    const alertContainer = document.getElementById('alertContainer');
    alertContainer.classList.remove('d-none');
    alertContainer.innerHTML = message;

    setTimeout(() => {
      alertContainer.classList.add('d-none');
      alertContainer.innerHTML = '';
    }, 2000);
  }

  document.getElementById('saveChanges').addEventListener('click', function(event) {
    const form = document.getElementById('editUserForm');
    const alertContainer = document.getElementById('alertContainer');
    alertContainer.classList.add('d-none');
    alertContainer.innerHTML = '';
  });
</script>



<script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
        <script>
      $(window).on('load', function () {
        $('.loading').hide();
        $('.cont-box').show();

        var table = $('#example').DataTable({
          scrollX: true,
          columnDefs: [
            { orderable: false, targets: [0, 2, 4, 5] }
          ],
          order: [[1, 'asc']]
   }); 
  });
    </script>
    <script>
      function editUser(userUuid) {
        var userRow = $('#dynamicTableBody').find('tr[data-uuid="' + userUuid + '"]');
        var name = userRow.find('td:nth-child(2)').text();
        var emailAddress = userRow.find('td:nth-child(3)').text();
        var type = userRow.find('td:nth-child(4)').text();
        var status = userRow.find('td:nth-child(5)').text();

        $('#user_Id').val(userUuid);
        $('#name').val(name);
        $('#emailAddress').val(emailAddress);
        $('#type').val(type);
        $('#status').val(status);

        $('#editUserModal').modal('show');
      }
    </script>
</body>

</html>
