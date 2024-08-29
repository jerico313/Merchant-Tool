<?php include ("../../header.php") ?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$promo_code = isset($_GET['promo_code']) ? $_GET['promo_code'] : '';
$changed_at = isset($_GET['changed_at']) ? $_GET['changed_at'] : '';
$changed_by = isset($_GET['changed_by']) ? $_GET['changed_by'] : '';

function displayOfferHistory($promo_code, $merchant_name)
{
  include ("../../inc/config.php");

  $sql = "SELECT ph.*, u.name FROM promo_history ph
            LEFT JOIN user u ON ph.changed_by = u.user_id
            WHERE ph.promo_code = ?";
  $stmt = $conn->prepare($sql);
  $stmt->bind_param("s", $promo_code); 
  $stmt->execute();
  $result = $stmt->get_result();

  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $shortPromoHistoryId = substr($row['promo_history_id'], 0, 8);
      echo "<tr>";
      echo "<td style='text-align:center;'>" . $shortPromoHistoryId . "</td>";
      echo "<td style='text-align:center;'>" . $row['old_bill_status'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['new_bill_status'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['changed_at'] . "</td>";
      echo "<td style='text-align:center;'>" . $row['name'] . "</td>";
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
  <title><?php echo htmlspecialchars($promo_code); ?> - Promo History</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link rel="stylesheet" href="../../style.css">
  <link rel="stylesheet" href="../../responsive-table-styles/promo_history.css">
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
        <div class="voucher-type">
          <div class="row pb-2 title" aria-label="breadcrumb">
            <nav aria-label="breadcrumb">
              <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                <li class="breadcrumb-item"><a href="../index.php" style="color:#E96529; font-size:14px;">Merchants</a>
                </li>
                <li class="breadcrumb-item dropdown">
                  <a href="#" class="dropdown-toggle" role="button" id="storeDropdown" data-bs-toggle="dropdown"
                    aria-expanded="false" style="color:#E96529;font-size:14px;">
                    Promos
                  </a>
                  <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                    <li><a class="dropdown-item"
                        href="../stores/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                        data-breadcrumb="Offers">Stores</a>
                    </li>
                    <li><a class="dropdown-item"
                        href="index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                        data-breadcrumb="Offers" style="color:#4BB0B8;">Promos</a>
                    </li>
                    <li><a class="dropdown-item"
                        href="../transactions/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                        data-breadcrumb="Offers">Transactions</a>
                    </li>
                  </ul>
                </li>
                <li class="breadcrumb-item"><a href="#" onclick="location.reload();"
                    style="color:#E96529; font-size:14px;">History</a></li>
              </ol>
            </nav>
            <p class="title2" style="padding-left:3px">
            <?php echo htmlspecialchars($promo_code); ?>
            </p>
          </div>
        </div>

        <div class="content">
          <table id="example" class="table bord" style="width:100%;">
            <thead>
              <tr>
                <th class="first-col">Promo History ID
                </th>
                <th style="padding:10px;">Old Bill Status</th>
                <th style="padding:10px;">New Bill Status</th>
                <th style="padding:10px;">Changed At</th>
                <th style="padding:10px;border-top-right-radius:10px;border-bottom-right-radius:10px;">Changed By</th>
              </tr>
            </thead>
            <tbody id="dynamicTableBody">
              <?php displayOfferHistory($promo_code, $merchant_name); ?>
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
    $(window).on('load', function () {
      $('.loading').hide();
      $('.cont-box').show();

      var table = $('#example').DataTable({
        scrollX: true,
        columnDefs: [
          { orderable: false, targets: [0] }
        ],
        order: [[3, 'asc']]
      });
    });
  </script>
</body>

</html>