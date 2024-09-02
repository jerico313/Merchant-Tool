<?php
session_start();
$email = "";
require 'Mailer/vendor/autoload.php'; 
include "inc/config.php";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

function sendEmail($to, $subject, $message)
{
    $mail = new PHPMailer();
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com'; 
    $mail->SMTPAuth = true;
    $mail->Username = 'booky.0318@gmail.com'; 
    $mail->Password = 'zktfeomgudhdcrhz'; 
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;

    $mail->setFrom('booky.0318@gmail.com', 'Booky');
    $mail->addAddress($to);

    $mail->Subject = $subject;
    $mail->isHTML(true);
    $mail->Body = $message;

    return $mail->send();
}

$alertMessage = ''; 

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["verify_code"])) {
    $verification_code = mt_rand(100000, 999999);
    $email = $_POST["email"];

    $check_email_sql = "SELECT user_id FROM user WHERE email_address = '$email'";
    $check_email_result = mysqli_query($conn, $check_email_sql);

    if (mysqli_num_rows($check_email_result) == 0) {
        $alertMessage = '<div class="alert-container alert alert-danger" role="alert">
                            <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Email not found. Please enter a valid email address.
                        </div>';
    } else {
        $update_query = "UPDATE user SET verification_code = '$verification_code' WHERE email_address = '$email'";

        if (mysqli_query($conn, $update_query)) {
            $subject = "Verification Code for Forgot Password";
            $message = '
                <html>
                <head>
                    <link rel="stylesheet" href="../../style.css">
                    <style>
                        .email-content {
                            font-family: Arial, sans-serif;
                            color: #333;
                            text-align:center;
                            padding: 20px;
                            background-color:#eeeeee;
                            border-radius:15px;
                        }
                        .code {
                            color: #E96529;
                            font-weight: 1000;
                            font-size: 40px;;
                        }
                        .logo {
                            width: 150px;
                        }
                    </style>
                </head>
                <body>
                    <div class="email-content">
                        <img src="cid:booky_logo" class="logo" alt="Booky Logo" style="padding-top:10px;"/>
                        <div class="">
                        <p style="font-weight:900;font-size:15px;color:#4BB0B8;">MERCHANT SETTLEMENT TOOL</p>
                        </div>
                        <p style="font-weight:900;">Your verification code is: <span class="code"><br>' . $verification_code . '</span></p>
                    </div>
                </body>
                </html>
            ';

            $mail = new PHPMailer();
            $mail->isSMTP();
            $mail->Host = 'smtp.gmail.com';
            $mail->SMTPAuth = true;
            $mail->Username = 'booky.0318@gmail.com'; 
            $mail->Password = 'zktfeomgudhdcrhz'; 
            $mail->SMTPSecure = 'tls';
            $mail->Port = 587;

            $mail->setFrom('booky.0318@gmail.com', 'Booky');
            $mail->addAddress($email);

            $mail->Subject = $subject;
            $mail->isHTML(true);
            $mail->Body = $message;

            $mail->addEmbeddedImage('images/booky2.png', 'booky_logo'); 

            if ($mail->send()) {
                $alertMessage = '<div class="alert-container alert alert-success" role="alert">
                                    <i class="fa-solid fa-circle-check" style="padding-right:3px"></i> Verification code sent to your email. Check your inbox.
                                </div>';
                $_SESSION['email'] = $email;
                header("Location: verify_change_password.php?email=$email");
                exit();
            } else {
                $alertMessage = '<div class="alert-container alert alert-danger" role="alert">
                                    <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Error sending verification code. Please try again later.
                                </div>';
            }
        } else {
            $alertMessage = '<div class="alert-container alert alert-danger" role="alert">
                                <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Error updating verification code. Please try again later.
                            </div>';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
    <title>Forgot Password</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@600&display=swap" rel="stylesheet">
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
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

        .verification-container {
            max-width: 400px;
            margin: 20px;
            padding: 20px;
            background-color: #fff;
            border-radius: 15px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            text-align: center;
            width: 350px;
            box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27);
            -webkit-box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27);
            -moz-box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27);
        }

        h3 {
            color: #4BB0B8;
            font-weight: 900;
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

        .alert-container {
            position: fixed;
            top: 0;
            right: 20px;
            transform: translateY(-50%);
            z-index: 1000;
            margin-top: 50px;
            width: auto;
            max-width: 80%;
            padding: 15px;
            font-size: 14px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            background-color: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
            border: 1px solid #dae0e5;
            border-left: solid 3px #f01e2c;
            box-sizing: border-box;
            opacity: 1;
            transition: opacity 1s ease-out;
        }

        .alert-container.fade-out {
            opacity: 0;
        }
    </style>
</head>

<body>
    <div class="verification-container">
        <?php if ($alertMessage): ?>
            <?php echo $alertMessage; ?>
        <?php endif; ?>
        <h3>Forgot your password?</h3>
        <p>Enter the email address associated with your account to change your password.</p>
        <form method="POST">
            <div class="form-group">
                <input type="email" name="email" placeholder="Enter email address" required>
            </div>
            <button type="submit" name="verify_code" class="btn-submit check-report">Request new password</button>
            <div class="register-link mt-3">
                <p>Already have an account? <a href="index.php" style="color:#4BB0B8;">Log in</a></p>
            </div>
        </form>
    </div>
</body>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        function fadeOutAlert() {
            const alert = document.querySelector('.alert-container');
            if (alert) {
                setTimeout(() => {
                    alert.classList.add('fade-out');
                }, 3000); 
            }
        }
        fadeOutAlert();
    });
</script>

</html>