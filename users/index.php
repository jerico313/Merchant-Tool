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
      echo "<td style='padding:13px 0;'>" . $shortUsertId . "</td>";
      echo "<td>" . $row['name'] . "</td>";
      echo "<td>" . $row['email_address'] . "</td>";
      echo "<td>" . $row['type'] . "</td>";
      echo "<td>" . $row['status'] . "</td>";
      echo "<td>";
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

    #alertContainer {
      width: 475px;
      font-size: 10px;
      background-color: #F8D7DA;
      border-radius: 5px;
      margin:5px 0;
    }

    select {
      background: transparent;
      border: 1px solid #ccc;
      padding: 5px;
      border-radius: 5px;
      color: #333;
      width: 80px;
    }

    select:focus {
      outline: none;
      box-shadow: none;
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
    Loading, Please wait...
  </div>
  <div class="cont-box">
    <div class="custom-box pt-4">
      <div class="sub" style="text-align:left;">
        <div class="add-btns">
          <p class="title"> <i class="fa-solid fa-user-gear fa-sm"></i> Manage Users</p>
          <a href="add_account.php"><button type="button" class="btn add-merchant"><i class="fa-solid fa-user-plus"></i> Create Account</button></a>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:100%;height:auto;">
            <thead>
            <tr>
                  <th class="first-col">User ID</th>
                  <th style="padding:10px;">Name</th>
                  <th style="padding:10px;">Email Address</th>
                  <th style="padding:10px;">Type</th>
                  <th style="padding:10px;">Status</th>
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
<!-- Edit Modal -->
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
        
        <form id="editUserForm" method="POST">
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
          <div class="mb-3">
            <label for="editPassword" style="display:block;">
              <input type="checkbox" id="editPassword" name="editPassword" style="accent-color:#E96529;vertical-align: middle; position: relative; bottom: 1px;" />
             Edit Password
            </label>
            <div id="alertContainer" class="alert alert-danger d-none" role="alert"></div>
          </div>
          <div class="mb-3" id="passwordContainer">
            <label for="password" class="form-label">
              New Password<span class="text-danger" style="padding:2px">*</span>
            </label>
            <input type="text" class="form-control mb-3" id="newPassword" name="newPassword" placeholder="Enter New password" required>
            <label for="password" class="form-label">
              Confirm Password<span class="text-danger" style="padding:2px">*</span>
            </label>
            <input type="text" class="form-control" id="confirmPassword" placeholder="Confirm New password" required>
          </div>
          <button type="submit" id="saveChanges" class="btn btn-primary"
            style="width:100%;background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;font-weight:700;">Save Changes
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    const editPasswordCheckbox = document.getElementById("editPassword");
    const passwordContainer = document.getElementById("passwordContainer");
    const newPasswordInput = document.getElementById("newPassword");
    const confirmPasswordInput = document.getElementById("confirmPassword");

    function togglePasswordField() {
      if (editPasswordCheckbox.checked) {
        passwordContainer.style.display = "block";
      } else {
        passwordContainer.style.display = "none";
        newPasswordInput.value = '';
        confirmPasswordInput.value = '';
      }
    }

    editPasswordCheckbox.addEventListener("change", togglePasswordField);

    // Initial toggle based on the checkbox state
    togglePasswordField();
  });

  function showAlert(message) {
    const alertContainer = document.getElementById('alertContainer');
    alertContainer.classList.remove('d-none');
    alertContainer.innerHTML = message;

    // Hide the alert after 2 seconds
    setTimeout(() => {
      alertContainer.classList.add('d-none');
      alertContainer.innerHTML = '';
    }, 2000);
  }

  document.getElementById('saveChanges').addEventListener('click', function(event) {
    const form = document.getElementById('editUserForm');
    const editPasswordCheckbox = document.getElementById('editPassword');
    const newPassword = document.getElementById('newPassword').value.trim();
    const confirmPassword = document.getElementById('confirmPassword').value.trim();

    // Reset alert
    const alertContainer = document.getElementById('alertContainer');
    alertContainer.classList.add('d-none');
    alertContainer.innerHTML = '';

    if (editPasswordCheckbox.checked) {
      // Check if password fields are empty
      if (newPassword === '' || confirmPassword === '') {
        showAlert('<i class="fa-solid fa-circle-exclamation"></i> Please enter both new password and confirm password.');
        event.preventDefault();
        return;
      }

      // Check if passwords match
      if (newPassword !== confirmPassword) {
        showAlert('<i class="fa-solid fa-circle-exclamation"></i> Passwords do not match.');
        event.preventDefault();
        return;
      }

      form.action = 'edit_password.php';
    } else {
      form.action = 'edit.php';
    }

    form.submit();
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
            { orderable: false, targets: [0, 2, 3, 4, 5] }
          ],
          order: [[1, 'asc']]
   }); 
  });
    </script>
    <!-- Edit Merchant Modal -->
    <script>
      function editUser(userUuid) {
        // Fetch the current data of the selected merchant
        var userRow = $('#dynamicTableBody').find('tr[data-uuid="' + userUuid + '"]');
        var name = userRow.find('td:nth-child(2)').text();
        var emailAddress = userRow.find('td:nth-child(3)').text();
        var type = userRow.find('td:nth-child(4)').text();
        var status = userRow.find('td:nth-child(5)').text();

    // Set values in the edit modal
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
