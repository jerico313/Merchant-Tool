<?php
session_start();

include("inc/config.php");

$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email_address'];
    $password = $_POST['password'];

    // Query to fetch user data
    $sql = "SELECT user_id, email_address, password, status FROM user WHERE email_address = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        if (password_verify($password, $row['password'])) {
            if ($row['status'] == 'Active') {
                $_SESSION['user_id'] = $row['user_id'];
                $_SESSION['email_address'] = $row['email_address'];

                // Debugging statement
                error_log("User authenticated and session variables set. Redirecting...");

                header("Location: merchant/");
                exit();
            } else {
                $error = "Your account is inactive. Please contact support.";
            }
        } else {
            $error = "Incorrect password.";
        }
    } else {
        $error = "Email not found.";
    }
    $stmt->close();
    $conn->close();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - Merchant Settlement Tool</title>
  <link rel="stylesheet" href="style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<style>
  * {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Nunito", sans-serif;
}

body {
  display: flex;
  justify-content: flex-start; /* Align content to the left */
  align-items: center;
  background: url('images/homebg.png') no-repeat center center/cover;
  background-size: cover; /* Ensure the background covers the entire element */
  height: 100vh; /
  padding: 20px; /* Add padding for spacing */
  padding-left: 245px;
}

.wrapper {
  width: 100%;
  max-width: 420px;
  background: transparent;
  color: #fff;
  border-radius: 10px;
  padding: 30px 40px;
  margin-left: 20px; /* Ensure there's space from the left */
}

.wrapper h1 {
  font-size: 1.5rem;
  font-weight: normal;
  text-align: center;
  margin: 0 0 12px;
}

.wrapper h2 {
  font-size: 1.25rem;
  font-weight: medium;
  text-align: center;
}

.wrapper h3 {
  font-size: 1.25rem;
  text-align: center;
}

.wrapper .input-box {
  position: relative;
  width: 100%;
  height: 50px;
  margin: 20px 0;
}

.input-box input {
  width: 100%;
  height: 100%;
  background: #fff;
  border: none;
  outline: none;
  border: 2px solid rgba(255, 255, 255, .2);
  border-radius: 40px;
  font-size: 1rem;
  color: #2A3240;
  padding: 20px 20px 20px 45px;
}

.input-box input::placeholder {
  color: #2A3240;
}

.input-box i {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.25rem;
}

.wrapper .remember-forgot {
  display: flex;
  justify-content: space-between;
  font-size: 1rem;
  margin: -15px 0 15px;
}

.remember-forgot label input {
  accent-color: #fff;
  margin-right: 5px;
}

.remember-forgot a {
  color: #fff;
  text-decoration: none;
}

.remember-forgot a:hover {
  text-decoration: underline;
}

.wrapper .btn {
  width: 100%;
  height: 45px;
  background: #4BB0B8;
  border: none;
  outline: none;
  border-radius: 40px;
  box-shadow: 0 0 10px rgba(0, 0, 0, .1);
  cursor: pointer;
  font-size: 1rem;
  color: #fff;
  font-weight: 600;
  margin-top: 20px;
}

.wrapper .btn:hover {
  background-color: #E96529;
  color: #fff;
  border: 2px solid rgba(255, 255, 255, .2);
}

.wrapper .btn:active {
  background: #fff;
  color: #4BB0B8;
  border: solid #fff 2px;
}

.wrapper .register-link {
  font-size: 1rem;
  text-align: center;
  margin: 20px 0 15px;
}

.register-link p a {
  color: #fff;
  text-decoration: none;
  font-weight: 600;
}

.register-link p a:hover {
  text-decoration: underline;
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

.input-box {
  position: relative;
  margin-bottom: 20px; /* Adjust as needed */
}

.input-icon {
  position: absolute;
  left: 10px; /* Adjust the position of the icon */
  top: 50%;
  transform: translateY(-50%);
  color: #999; /* Adjust the color of the icon */
  pointer-events: none; /* Ensures the icon does not interfere with input */
}

.input-icon {
  position: absolute;
  left: 10px; /* Adjust the position of the icon */
  top: 50%;
  transform: translateY(-50%);
  color: #999; /* Adjust the color of the icon */
  pointer-events: none; /* Ensures the icon does not interfere with input */
}

.toggle-password:hover {
  color: #666; /* Adjust the color when hovered */
}

@media (max-width: 600px) {
  body {
    padding: 20px; /* Maintain padding for smaller screens */
    background: #E96529; 
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
</style>

<body>
  <div class="wrapper">
    <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="POST">
      <h3 class="text-center mb-4"><img src="images/bookylog.png" alt="booky" height="98" width="180"></h3>
      <h1>Merchant Settlement Tool</h1>
      <h2>Login</h2><br></br>
      <?php if (!empty($error)): ?>
        <div class="alert-custom alert alert-danger" role="alert">
            <i class="fa-solid fa-circle-exclamation"></i> <?php echo $error; ?>
        </div>
      <?php endif; ?>
      <div class="input-box">
  <i class="fa-solid fa-user input-icon" style="margin-left:10px;"></i>
  <input type="text" style="padding-left: 50px !important;"placeholder="Enter your Email" name="email_address" required>
</div>

<div class="input-box">
  <i class="fa-solid fa-lock input-icon"  style="margin-left:10px;"></i>
  <input type="password" placeholder="Password" name="password" id="password" required>
</div>

      <div class="remember-forgot" style= "display:none">
        <label><input type="checkbox"> Remember me</label>
        <a href="#" style= "display:none">Forgot password? </a>
      </div>
      <button type="submit" class="btn" name="login">Login</button>
      <div class="register-link">
        <p>Don't have an account?<a href="register.php"> Register</a></p>
      </div>
    </form>
  </div>

</body>
</html>
