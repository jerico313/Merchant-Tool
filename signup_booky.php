<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sign Up</title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
  <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link rel="stylesheet" href="style.css">
  <style>
    body {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f0f0f0;
  background-image: url("images/LEADGEN.png");
  background-color: #cccccc;
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
  background-attachment: fixed;
}
  </style>
</head>
<body>
  <div class="login-container">
    <center><img src="images/booky.png" alt="booky" height="85" width="150"></center>
    <p class="text-center mb-4" style="color:#fff;font-size:20px;font-weight:bold;">Create Account</p>
    <form action="signup.php" method="post">

  <div data-mdb-input-init class="form-outline mb-4">
    <input type="text" id="name" name="name" class="form-control" style="border-radius:20px;padding:18px;border:none;" placeholder="Full Name" required>
  </div>

  <div data-mdb-input-init class="form-outline mb-4">
    <input type="email" id="email" name="email" class="form-control" style="border-radius:20px;padding:18px;border:none;" placeholder="Email" required>
  </div>

  <div data-mdb-input-init class="form-outline mb-4">
    <input type="password" id="password" name="password" class="form-control" style="border-radius:20px;padding:18px;border:none;" placeholder="Password" required>
  </div>

  <div data-mdb-input-init class="form-outline mb-4">
    <input type="password" id="confirm_password" name="confirm_password" class="form-control" style="border-radius:20px;padding:18px;border:none;" placeholder="Confirm Password" required>
  </div>
  <br>

  <!-- Submit button -->
  <button style="border-radius:20px;background-color:#fff;color:black;border:none;font-size:12px;color:#F47831;font-weight:bold;padding:8px" type="submit" data-mdb-button-init data-mdb-ripple-init class="btn btn-primary btn-block mb-4">Sign Up</button>
  </div>
</form>
  </div>
</body>
</html>