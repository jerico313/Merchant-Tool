<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
    <title>Password Sent</title>
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
  z-index: -1; 
  left: 0;
  width: 100%;
  height: 100%;  
  background: rgba(0, 0, 0, 0.3);
  background-attachment: fixed; 
}
.message-container {
    max-width: 400px;
    margin: 20px;
    padding: 20px;
    background-color: #fff;
    border-radius: 15px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    text-align: center;
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

.checkmark { 
            width: 80px; 
            height: 80px; 
            border-radius: 50%;
            display: block; 
            margin: 0 auto; 
        }
        .checkmark circle { 
            stroke-width: 4; 
            stroke-miterlimit: 10; 
            stroke: $color; 
            fill: none; 
        }
        .checkmark line, .checkmark path { 
            stroke-dasharray: 48;
            stroke-dashoffset: 48;
            stroke-width: 4;
            stroke-linecap: round;
            stroke-miterlimit: 10;
            stroke: $color; 
            fill: none; 
            animation: draw 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards; 
        }
        @keyframes draw { 
            0% { stroke-dashoffset: 48; } 
            100% { stroke-dashoffset: 0; } 
        }
        .error-list {
            font-size: 14px; 
            text-align: left; 
            margin-top: 10px;
            padding-left: 0;
            list-style-type: none; 
        }
        .error-list li {
            margin-bottom: 5px; 
        }
    </style>
</head>
<body>
    <div class="message-container">
        <h3>Password Sent</h3>
        <p>Please check your email for the temporary password. Use the provided temporary password to log in and update your password.</p>
        <a href="index.php" class="btn-submit check-report">Login</a>
    </div>
</body>
</html>
