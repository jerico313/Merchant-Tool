<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login </title>
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
    <h2 class="text-center mb-4"><img src="images/booky.png" alt="booky" height="85" width="150"></h2>
    <form>
  <!-- Email input -->
  <div data-mdb-input-init class="form-outline mb-4">
    <input type="email" id="form2Example1" class="form-control" style="border-radius:20px;padding:18px;border:none;" placeholder="Username"/>
  </div>

  <!-- Password input -->
  <div data-mdb-input-init class="form-outline mb-4">
    <input type="password" id="form2Example2" class="form-control" style="border-radius:20px;padding:18px;border:none;" placeholder="Password"/>
  </div>

  <!-- 2 column grid layout for inline styling -->
  <div class="row mb-4">
    <div class="col d-flex justify-content">
      <!-- Checkbox -->
      <div class="form-check" style="color:#fff;">
        <input class="form-check-input" type="checkbox" value="" id="form2Example31" />
        <label class="form-check-label" for="form2Example31" style="font-size:10px;"> Remember Password </label>
      </div>
    </div>
  </div>

  <!-- Submit button -->
  <button style="border-radius:20px;background-color:#fff;color:black;border:none;font-size:12px;color:#F47831;font-weight:bold;padding:8px" type="button" data-mdb-button-init data-mdb-ripple-init class="btn btn-primary btn-block mb-4">Login</button>
  </div>
</form>
  </div>
</body>
</html>