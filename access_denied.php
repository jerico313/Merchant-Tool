<?php require_once("header.php")?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
  <meta http-equiv="X-UA-Compatible" content="IE-edge">
  <meta name="viewport" content="width=device-width,initial-scale=1.0 ">
  <title> Access Denied</title>
  <link rel="stylesheet" href="style.css">
</head>
<style>
  *{
    margin:center;
    padding: 0;
    box-sizing: border-box;
    font-family: "Nunito", sans-serif;
  }
body {
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: url('images/bg_booky.png') no-repeat;
  background-size: cover;
  background-position: center;   
}
.wrapper{
  width: 40%;
  margin-top:50px;
  margin-left:auto;
  margin-right:auto;
  color: #E96529;
  padding: 10px 10px 30px 10px;
  border-radius: 30px;
background: #f1f1f1;
box-shadow:  5px 5px 10px #cdcdcd,
             -5px -5px 10px #ffffff;
}

</style>



<body>
  <div class="wrapper">
  <h3 class="text-center"><img src="images/barrier.png" height="210" width="400" style="padding:0px;filter: drop-shadow(5px 5px 5px #989898);"></h3>  
      <p style="text-align:center;font-size:40px;font-weight:900;">Access Denied</p>
      <p style="text-align:center;font-size:20px;font-weight:700;">You do not have permission to access this page.<br> You can go back to <a href="javascript:history.go(-1)" style="text-align:center;color:#4BB0B8;font-size:20px;font-weight:700;">previous page.</a></p>
</div>
</body>

</html>
