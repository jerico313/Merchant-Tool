<?php
session_start();

include("inc/config.php");

$error = "";
$lockout_duration = 5 * 60; 
$remaining_time = 0; 

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email_address'];
    $password = $_POST['password'];

    $sql = "SELECT user_id, email_address, password, status, login_attempts, lockout_time FROM user WHERE email_address = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();

        if ($row['lockout_time'] && strtotime($row['lockout_time']) > time()) {
            $remaining_time = strtotime($row['lockout_time']) - time();
            $error = "Account is locked. Please wait &nbsp;<span id='countdown'></span>&nbsp; seconds.";
        } else {
            if ($row['lockout_time'] && strtotime($row['lockout_time']) <= time()) {
                $sql_reset_lockout = "UPDATE user SET login_attempts = 0, lockout_time = NULL WHERE email_address = ?";
                $stmt_reset_lockout = $conn->prepare($sql_reset_lockout);
                $stmt_reset_lockout->bind_param("s", $email);
                $stmt_reset_lockout->execute();
                $stmt_reset_lockout->close();
                $row['login_attempts'] = 0; 
            }

            if (password_verify($password, $row['password'])) {
                if ($row['status'] == 'Active') {
                    $sql_reset_attempts = "UPDATE user SET login_attempts = 0, lockout_time = NULL WHERE email_address = ?";
                    $stmt_reset = $conn->prepare($sql_reset_attempts);
                    $stmt_reset->bind_param("s", $email);
                    $stmt_reset->execute();
                    $stmt_reset->close();

                    $_SESSION['user_id'] = $row['user_id'];
                    $_SESSION['email_address'] = $row['email_address'];

                    header("Location: merchants/");
                    exit();
                } else {
                    $error = "Your account is inactive. Please contact admin.";
                }
            } else {
                $new_attempts = $row['login_attempts'] + 1;
                if ($new_attempts >= 3) {
                    $lockout_time = date("Y-m-d H:i:s", strtotime("+$lockout_duration seconds"));
                    $sql_lock_account = "UPDATE user SET login_attempts = ?, lockout_time = ? WHERE email_address = ?";
                    $stmt_lock = $conn->prepare($sql_lock_account);
                    $stmt_lock->bind_param("iss", $new_attempts, $lockout_time, $email);
                    $stmt_lock->execute();
                    $stmt_lock->close();

                    $error = "Too many incorrect attempts. Your account is locked for 5 minutes.";
                    $remaining_time = $lockout_duration;
                } else {
                    $sql_update_attempts = "UPDATE user SET login_attempts = ? WHERE email_address = ?";
                    $stmt_update = $conn->prepare($sql_update_attempts);
                    $stmt_update->bind_param("is", $new_attempts, $email);
                    $stmt_update->execute();
                    $stmt_update->close();

                    $error = "Incorrect password. Attempt $new_attempts of 3.";
                }
            }
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
  <title>Login</title>
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
  justify-content: flex-start;
  align-items: center;
  background: url('images/homebg.png') no-repeat center center/cover;
  background-size: cover; 
  height: 100vh; 
  padding: 20px;
  padding-left: 245px;
}

.wrapper {
  width: 100%;
  max-width: 420px;
  background: transparent;
  color: #fff;
  border-radius: 10px;
  padding: 30px 40px;
  margin-left: 20px; 
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
  margin-bottom: 20px; 
}

.input-icon {
  position: absolute;
  left: 10px;
  top: 50%;
  transform: translateY(-50%);
  color: #999;
  pointer-events: none; 
}

.input-icon {
  position: absolute;
  left: 10px; 
  top: 50%;
  transform: translateY(-50%);
  color: #999; 
  pointer-events: none; 
}

.toggle-password:hover {
  color: #666;
}

@media (max-width: 600px) {
  body {
    padding: 20px; 
    background: #E96529; 
  }

  .wrapper {
    padding: 20px;
    margin-left: 10px; 
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
      <p style="font-weight:900;text-align:center;font-size:15px;">Merchant Settlement Tool</p><br>
      <h2>Login</h2><br></br>
      <?php if (!empty($error)): ?>
        <div class="alert-custom alert alert-danger" role="alert">
            <i class="fa-solid fa-circle-exclamation"></i> <?php echo $error; ?>
        </div>
      <?php endif; ?>
      <div class="input-box">
  <i class="fa-solid fa-user input-icon" style="margin-left:10px;"></i>
  <input type="text" style="padding-left: 50px !important;"placeholder="Email address" name="email_address" required>
</div>

<div class="input-box">
  <i class="fa-solid fa-lock input-icon"  style="margin-left:10px;"></i>
  <input type="password" placeholder="Password" name="password" id="password" required>
</div>

      <div class="remember-forgot" style="padding:3px 15px;">
      <label class="form-check-label" style="display:block;margin-top:5x;">
        <input type="checkbox" class="form-check-input" id="showPassword" name="showPassword" style="vertical-align: middle;position: relative; ">
        Show password
      </label>
        <a href="forgot_password.php">Forgot password?</a>
      </div>
      <button type="submit" class="btn" name="login">Login</button>
     
    </form>
  </div>
  <script>
    document.getElementById('showPassword').addEventListener('change', function() {
      var passwordInput = document.getElementById('password');
      if (this.checked) {
        passwordInput.type = 'text';
      } else {
        passwordInput.type = 'password';
      }
    });

    document.getElementById('loginForm').addEventListener('submit', function(e) {
      var form = this;
      var requiredFields = form.querySelectorAll('[required]');
      var allValid = true;

      requiredFields.forEach(function(field) {
        if (!field.value) {
          alert('Required field "' + field.getAttribute('placeholder') + '" should not be blank.');
          field.focus();
          allValid = false;
          e.preventDefault(); 
          return false;
        }
      });

      return allValid;
    });
  </script>
    <script>
    var remainingTime = <?php echo $remaining_time; ?>;
    if (remainingTime > 0) {
      var countdownDisplay = document.getElementById('countdown');

      var countdown = setInterval(function() {
        countdownDisplay.textContent = remainingTime;
        remainingTime--;

        if (remainingTime <= 0) {
          clearInterval(countdown);
          window.location.href = 'index.php'; 
        }
      }, 1000);
    }
  </script>
</body>
</html>
