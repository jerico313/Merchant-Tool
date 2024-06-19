<?php require_once("../header.php")?>
<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
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

    .back {
            font-size: 20px;
            font-weight: bold;
            margin-right: auto;
            padding-left: 5vh;
            color: #E96529;
        }

</style>
<script>
  function editEmployee(id) {
    window.location = "edit_order.php?order_id=" + id;
  }
</script>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-5">
  <a href="javascript:history.back()">
            <p class="back"><i class="fa-regular fa-circle-left fa-lg"></i></p>
        </a>
    <div class="sub" style="text-align:left;">
      <div class="add-btns">
        <p class="title">Settlement Report</p>
      </div>
      <div class="content" style="margin:25px;">
      <div class="text-center" style="text-align:center;" style="width:100%;">
  <div class="row">
  <div class="col">
  <a href="reports/coupled.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"><div class="btn" style="background-color:#4BB0B8; height:100px; border-radius:20px; margin:5px; display: flex; justify-content: center; align-items: center;">
  <span style="font-size:20px;color:#fff;padding-top:15px"><i class="fa-solid fa-folder fa-2xl"></i><span>  
    <p style="padding-top:5px;font-size:15px;">Coupled</p>
  </div></a>
  </div>
    <div class="col">
    <a href="reports/decoupled.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"><div class="btn" style="background-color:#4BB0B8; height:100px; border-radius:20px; margin:5px; display: flex; justify-content: center; align-items: center;">
  <span style="font-size:20px;color:#fff;padding-top:15px"><i class="fa-solid fa-folder fa-2xl"></i><span>  
    <p style="padding-top:5px;font-size:15px;">Decoupled</p>
  </div></a>
    </div>
    <div class="col">
    <a href="reports/gcash.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"><div class="btn" style="background-color:#4BB0B8; height:100px; border-radius:20px; margin:5px; display: flex; justify-content: center; align-items: center;">
  <span style="font-size:20px;color:#fff;padding-top:15px"><i class="fa-solid fa-folder fa-2xl"></i><span>  
    <p style="padding-top:5px;font-size:15px;">GCash</p>
  </div></a>
    </div>
  </div>
</div>
</div>
      
    </div>
  </div>
</div>


</body>
</html>
