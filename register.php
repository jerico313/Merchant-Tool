<?php
require 'inc/config.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $conn->real_escape_string($_POST['name']);
    $email = $conn->real_escape_string($_POST['email']);
    $type = $conn->real_escape_string($_POST['type']);

    $password = $conn->real_escape_string($_POST['password']);
    $confirm_password = $conn->real_escape_string($_POST['confirm_password']);

    if ($password === $confirm_password) {
        $hashed_password = password_hash($password, PASSWORD_BCRYPT);

        $stmt = $conn->prepare("INSERT INTO user (name, email_address, type, password) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $name, $email, $type, $hashed_password);

        if ($stmt->execute()) {
          echo "<script>alert('Record added successfully'); window.location = 'index.php';</script>";
        } else {
            echo "Error: " . $stmt->error;
        }

        $stmt->close();
    } else {
        $error = "Passwords do not match";
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
  <title> Register Account</title>
  <link rel="stylesheet" href="style.css">
</head>
<style>
  *{
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: "Nunito", sans-serif;
  }
  body {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: url('images/registerbg.png') no-repeat;
  background-size: cover;
  background-position: center;
    

}
.wrapper{
  width: 420px;
  background: transparent;
  
  color: #fff;
  border-radius: 10px;
  padding: 30px 40px;
}

.wrapper h1{
  font-size: 18px;
  font-weight: normal;
  text-align: center;
  margin:0 0 12px;
}
.wrapper h2{
  font-size: 15px;
  font-weight: medium;
  text-align: center;

}
.wrapper h3{
  font-size: 15px;
  text-align: center;
}

.wrapper .input-box {
  position: relative;
  width: 100%;
  height: 50px;
  margin: 28px 0;
  margin-top: 18px;
}

.input-box input {
  width: 100%;
  height: 100%;
  background: #fff;
  border: none;
  outline: none;
  border: 2px solid rgba(255, 255, 255, .2);
  border-radius: 40px;
  font-size: 16px;
  color: #2A3240;
  padding: 20px 45px 20px 20px;

}

.option {
  width: 100%;
  height: 100%;
  border: 2px solid rgba(255, 255, 255, .2);
  border-radius: 40px;
  border: none;
  outline: none;
  font-size: 16px;
  color: #2A3240;
  padding: 12px 55px 12px 18px;

}

.input-box input::placeholder{
color: #2A3240;

}

.input-box i {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.5rem;
  }


.wrapper .remember-forgot{
  display: flex;
  justify-content: space-between;
  font-size: 14.5px;
  margin: -15px 0 15px;
  margin-top: 15px;
}

.remember-forgot label input{
  accent-color: #fff;
  margin-right: 3px;
}

.remember-forgot a{
  color: #fff;
  text-decoration: none;
}

.remember-forgot a:hover{
  text-decoration: underline;
}

.wrapper .btn{
  width: 100%;
  height: 45px;
  background: #4BB0B8;
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
  background-color: #E96529;
  color:#fff;
  border: 2px solid rgba(255, 255, 255, .2);
}

.wrapper .btn:active{
  background: #fff;
  color:#4BB0B8;
  border:solid #fff 2px;
}

.wrapper .register-link {
  font-size: 14.5px;
  text-align: center;
  margin: 20px 0 15px;

}

.register-link p a{
  color: #fff;
  text-decoration: none;
  font-weight: 600;
}

.register-link p a:hover {
  text-decoration: underline;
}

@media (max-width: 600px) {
  body {
    padding: 20px; /* Maintain padding for smaller screens */
  }

  .wrapper {
    padding: 20px;
    margin-left: 10px; /* Reduce margin for smaller screens */
  }

  .input-box input {
    padding: 15px 15px 15px 40px;
    
  }

  .input-box i {
    font-size: 1rem;
  }

  .wrapper h1, .wrapper h2, .wrapper h3 {
    font-size: 1.25rem;
  }
}

.alert-custom {
  border-left: solid 3px #f01e2c;
  padding: 10px;
  background-color: #f8d7da;
  color: #721c24;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
}

.alert-custom i {
  margin-right: 10px;
}


</style>



<body>
  <div class="wrapper">
    <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>"  method="POST"  >
      <h3 class="text-center mb-4"><img src="images/bookylog.png" alt="booky" height="98" width="180"></h3>
      <h1>Merchant Settlement Tool</h1>
      <h2>Register Account</h2>
      <div class="input-box">
        <input type="text" placeholder="Email" name="email"required>
      </div>
      <div class="input-box">
        <input type="text" placeholder="Name" name="name"required>
      </div>
      <div class="input-box" style= "display:none">
        <input type="text" placeholder="Position" value="User" name="type" readonly required >
      </div>
      <div class="input-box">
        <input type="password" placeholder="Create password" name="password" required>
        <i class= 'bx bxs-lock-alt'></i>  
      </div>
      <div class="input-box">
        <input type="password" placeholder="Confirm password" name="confirm_password" required>
        <i class= 'bx bxs-lock-alt'></i>  
      </div>
      <?php if (!empty($error)): ?>
        <div class="alert-custom alert alert-danger" role="alert">
            <i class="fa-solid fa-circle-exclamation"></i> <?php echo $error; ?>
        </div>
      <?php endif; ?>
        <button type="submit" class="btn">Submit</button>

        <div class="register-link">
         <p>Already have an account? <a href="index.php"> Login</a></p> 
      </div>
    </form>
</div>
</body>

</html>
