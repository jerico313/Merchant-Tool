<?php
$email = isset($_GET['email']) ? $_GET['email'] : '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
    <title>Verify Code</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <style>
            body {
              background: url('images/registerbg.png') no-repeat;
      background-color: #cccccc;
      background-position: center;
      background-repeat: no-repeat;
      background-size: cover;
      background-attachment: fixed;
      font-family: Manrope;
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
    }


    body::before {
  content: "";
  position: absolute;
  top: 0;
  z-index: -1; /* Move the pseudo-element to the background */
  left: 0;
  width: 100%;
  height: 100%;  
  background: rgba(0, 0, 0, 0.3); /* Adjust alpha value for darkness */
  background-attachment: fixed; /* Ensure the dark overlay doesn't move */
}
.verification-container {
    max-width: 400px;
    margin: 20px;
    padding: 20px;
    background-color: #fff;
    border-radius: 15px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);

    width:350px;
    box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27);
  -webkit-box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27);
  -moz-box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27);
}

h3 {
    color: #4BB0B8 ;
    font-weight: 900;
    text-align: center;
}

p {
    color: #555;
}

.form-group {
    margin-bottom: 20px;
}

label {
    display: block;
    font-weight: bold;
    margin-bottom: 5px;
}

input {
    width: 100%;
    padding: 10px;
    box-sizing: border-box;
    border: 1px solid #ccc;
    border-radius: 5px;
}

.btn-submit {
    width: 100%;
}

    </style>
</head>
<body>
    <div class="verification-container">
        <h3>Forgot Password</h3>
        <p>Enter the verification code sent to your email address.</p>
        <form action="change_pass.php" method="post">
            <div class="form-group">
                <label for="verification_code">Verification Code:</label>
                <input type="text" name="verification_code" required>
            </div>
            <button type="submit" name="verify" class="btn-submit check-report">Verify</button>
        </form>
        <form action="change_pass.php" method="post" class="mt-3">
        <input type="hidden" name="email"
        value="<?php echo htmlspecialchars($email); ?>">
            <button type="submit" name="resend_code" class="btn-submit resend">Resend Code</button>
        </form>
    </div>
</body>
</html>
