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
          echo "<tr data-id='" . $row['user_id'] . "'>";
          echo "<td style='text-align:center;'>" . $shortUserId . "</td>";
          echo "<td style='text-align:center;'>" . $row['name'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['email_address'] . "</td>";
          echo "<td style='text-align:center;'>" . $row['type'] . "</td>";
          if ($row['status'] == '') {
            // Display two buttons in a column if status is blank
            echo "<td style='text-align:center;'>
                    <button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#95DD59;color:black;' onclick='changeStatus(\"" . $row['user_id'] . "\", \"Active\")'>Active</button>
                    <button class='btn btn-success btn-sm' style='border:none; border-radius:20px;width:60px;background-color:#E8C0AE;color:black;' onclick='changeStatus(\"" . $row['user_id'] . "\", \"Inactive\")'>Inactive</button>
                  </td>";
        } else {
            echo "<td style='text-align:center;'>". $row['status'] . "</td>";
        }
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
      font-weight: bold; 
      margin-right: auto; 
      padding-left: 5vh;
      color: #E96529;
    }

    .add-btns{
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
      text-align:left !important;
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
      text-align:left !important;
      font-weight:bold;
    }

    .table td:nth-child(1) {
      background: #E96529;
      height: 100%;
      top: 0;
      left: 0;
      font-weight: bold;
      color:#fff;
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

    .dataTables_length {
      display: none;
    }

    .title{
      font-size: 25px;
      padding-left: 2vh;
      padding-top:10px;
    }
  
    .add-btns{
      padding-right: 2vh;
      padding-bottom: 10px;
    }
  }
</style>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-4">
    <div class="sub" style="text-align:left;">
      <div class="add-btns">
        <p class="title">Users</p>
        <!-- Form to upload file -->
        
        
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
              <th>Status</th>
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
});

function changeStatus(userId, status) {
  // Make an AJAX call to update the status in the database
  $.ajax({
    type: 'POST',
    url: 'update_status.php', // Create a PHP file to handle the status update
    data: { userId: userId, status: status },
    success: function(response) {
      // Update the status in the table immediately after the button click
      if (status === 'Active') {
        $(`tr[data-id='${userId}'] td:nth-child(5)`).text('Active');
      } else if (status === 'Inactive') {
        $(`tr[data-id='${userId}'] td:nth-child(5)`).text('Inactive');
      }
    },
    error: function(xhr, status, error) {
      console.error('Error updating status: ' + error);
    }
  });
}
</script>
</body>
</html>

