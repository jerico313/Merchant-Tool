<?php require_once("../../../header.php")?>
<?php
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Settlement Reports</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
<link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
<script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="../../../style.css">
<style>
    body {
      background-image: url("../../../images/bg_booky.png");
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
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-4">
  <div class="voucher-type">
                <div class="row pb-2 title" aria-label="breadcrumb">
                <nav aria-label="breadcrumb">
                        <ol class="breadcrumb" style="--bs-breadcrumb-divider: '|';">
                            <li class="breadcrumb-item"><a href="../index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" style="color:#E96529; font-size:14px;">Store</a></li>
                            <li class="breadcrumb-item dropdown">
                <a href="#" class="dropdown-toggle" role="button" id="storeDropdown" data-bs-toggle="dropdown"
                  aria-expanded="false" style="color:#E96529;font-size:14px;">
                  Settlement Reports
                </a>
                <ul class="dropdown-menu" aria-labelledby="storeDropdown">
                  <li><a class="dropdown-item"
                      href="../store/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                      data-breadcrumb="Offers">Stores</a>
                  </li>
                  <li><a class="dropdown-item"
                      href="../promo/index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                      data-breadcrumb="Offers">Promos</a>
                  </li>
                  <li><a class="dropdown-item"
                      href="index.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                      data-breadcrumb="Offers" style="color:#4BB0B8;">Settlement Reports</a>
                  </li>
                </ul>
              </li>                               
                        </ol>
                    </nav> 
                </div>
            </div>
    <div class="sub" style="text-align:left;">
      <div class="add-btns">
      <p class="title" style="color:#4BB0B8;font-size:30px;text-shadow: 3px 3px 5px rgba(99,99,99,0.35);"><?php echo htmlspecialchars($store_name, ENT_QUOTES, 'UTF-8'); ?> </p>
      </div>
      <div class="content" style="margin:25px;">
      <div class="text-center" style="text-align:center;" style="width:100%;">
  <div class="row">
  <div class="col">
  <a href="coupled.php?store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>&merchant_id=<?php echo htmlspecialchars($merchant_id); ?>"><div class="btn" style="background-color:#4BB0B8; height:100px; border-radius:20px; margin:5px; display: flex; justify-content: center; align-items: center;">
  <span style="font-size:20px;color:#fff;padding-top:15px"><i class="fa-solid fa-folder fa-2xl"></i><span>  
    <p style="padding-top:5px;font-size:15px;">Coupled</p>
  </div></a>
  </div>
    <div class="col">
    <a href="decoupled.php?store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>&merchant_id=<?php echo htmlspecialchars($merchant_id); ?>"><div class="btn" style="background-color:#4BB0B8; height:100px; border-radius:20px; margin:5px; display: flex; justify-content: center; align-items: center;">
  <span style="font-size:20px;color:#fff;padding-top:15px"><i class="fa-solid fa-folder fa-2xl"></i><span>  
    <p style="padding-top:5px;font-size:15px;">Decoupled</p>
  </div></a>
    </div>
    <div class="col">
    <a href="gcash.php?store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>&merchant_id=<?php echo htmlspecialchars($merchant_id); ?>"><div class="btn" style="background-color:#4BB0B8; height:100px; border-radius:20px; margin:5px; display: flex; justify-content: center; align-items: center;">
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
