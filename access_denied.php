<?php require_once("header.php")?>


<?php
require 'inc/config.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $conn->real_escape_string($_POST['username']);
    $email = $conn->real_escape_string($_POST['email']);
    $password = password_hash($conn->real_escape_string($_POST['password']), PASSWORD_BCRYPT);

    $sql = "INSERT INTO users (username, email, password) VALUES ('$username', '$email', '$password')";

    if ($conn->query($sql) === TRUE) {
        echo "Registration successful";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }

    $conn->close();
}
?>



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
  width: 50%;
  background: rgba(75, 176, 184, 0.5);
  border: 2px solid rgba(255, 255, 255, .2);
  backdrop-filter: blur(50px);
  margin-top:150px;
  margin-left:auto;
  margin-right:auto;
  color: #fff;
  border-radius: 10px;
  padding: 50px 60px;

  
}

.wrapper h1{
  font-size:20px;
  font-weight: bold;
  text-align: center;
  margin:0 0 12px;
  
}
.wrapper h2{
  font-size: 15px;
  font-weight: medium;
  text-align: center;

}
.wrapper i{
  font-size: 80px;
  margin:auto;
  margin:text-center mb-4;
}


.wrapper .btn{
  width: 100%;
  height: 45px;
  background: #E96529;
  border: none;
  outline: none;
  border-radius: 40px;
  box-shadow: 0 0 10px rgba(0, 0, 0, .1);
  cursor: pointer;
  font-size: 16px;
  color: #fff;
  font-weight: 600;
  margin-top: 20px;
}

.wrapper .btn:hover{
  background-color: #4BB0B8;
  color:#fff;
  border: 2px solid rgba(255, 255, 255, .2);
}

.wrapper .btn:active{
  background: #fff;
  color:#4BB0B8;
  border:solid #fff 2px;
}

</style>



<body>
  <div class="wrapper">
    <form action="">
    <h3 class="text-center mb-4"><img src="images/accessd.png" alt="booky" height="98" width="180"></h3>
      <h1>Access Denied</h1>
      <h2>You do not have permission to access this page.</h2>
        <button type="submit" class="btn">Submit</button>
    </form>
</div>
</body>

</html>
