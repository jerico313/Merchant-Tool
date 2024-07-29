<?php
session_start();
$email = "";
require 'Mailer/vendor/autoload.php'; // Include Composer autoloader
include "inc/config.php";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

function sendEmail($to, $subject, $message) {
    // Create a new PHPMailer instance
    $mail = new PHPMailer();
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com'; // Replace with your SMTP server
    $mail->SMTPAuth = true;
    $mail->Username = 'jericobuncag0@gmail.com'; // Replace with your SMTP username
    $mail->Password = 'zswmpiantsrswvci'; // Replace with your SMTP password
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;

    $mail->setFrom('jericobuncag0@gmail.com', 'PNR'); // Replace with your email and name
    $mail->addAddress($to);

    $mail->Subject = $subject;
    $mail->isHTML(true);
    $mail->Body = $message;

    return $mail->send();
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["verify_code"])) {
    $verification_code = mt_rand(100000, 999999);
    $email = $_POST["email"];

    $check_email_sql = "SELECT user_id FROM user WHERE email_address = '$email'";
    $check_email_result = mysqli_query($conn, $check_email_sql);

    if (mysqli_num_rows($check_email_result) == 0) {
        echo "<script>alert('Email not found. Please enter a valid email address.'); window.location = 'forgot_password.php';</script>";
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
                        <img src="cid:booky_logo" class="logo" alt="Booky Logo" />
                        <div class="">
                        <p style="font-weight:900;font-size:15px;">Merchant Settlement Tool</p>
                        </div>
                        <p style="font-weight:900;">Your verification code is: <span class="code"><br>' . $verification_code . '</span></p>
                    </div>
                </body>
                </html>
            ';

            $mail = new PHPMailer();
            $mail->isSMTP();
            $mail->Host = 'smtp.gmail.com'; // Replace with your SMTP server
            $mail->SMTPAuth = true;
            $mail->Username = 'jericobuncag0@gmail.com'; // Replace with your SMTP username
            $mail->Password = 'zswmpiantsrswvci'; // Replace with your SMTP password
            $mail->SMTPSecure = 'tls';
            $mail->Port = 587;

            $mail->setFrom('jericobuncag0@gmail.com', 'BOOKY');
            $mail->addAddress($email);

            $mail->Subject = $subject;
            $mail->isHTML(true);
            $mail->Body = $message;

            // Attach logo image
            $mail->addEmbeddedImage('images/booky2.png', 'booky_logo'); // Adjust path as needed

            if ($mail->send()) {
                echo "Verification code sent to your email. Check your inbox.";
                $_SESSION['email'] = $email;
                header("Location: verify_change_pass.php?email=$email");
                exit();
            } else {
                echo "Error sending verification code. Please try again later.";
            }
        } else {
            echo "Error updating verification code. Please try again later.";
        }
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["resend_code"])) {
    $verification_code = mt_rand(100000, 999999);
    $email = $_POST["email"];

    $check_email_sql = "SELECT user_id FROM user WHERE email_address = '$email'";
    $check_email_result = mysqli_query($conn, $check_email_sql);

    if (mysqli_num_rows($check_email_result) == 0) {
        echo "<script>alert('Email not found. Please enter a valid email address.'); window.location = 'forgot_password.php';</script>";
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
            $mail->Host = 'smtp.gmail.com'; // Replace with your SMTP server
            $mail->SMTPAuth = true;
            $mail->Username = 'jericobuncag0@gmail.com'; // Replace with your SMTP username
            $mail->Password = 'zswmpiantsrswvci'; // Replace with your SMTP password
            $mail->SMTPSecure = 'tls';
            $mail->Port = 587;

            $mail->setFrom('jericobuncag0@gmail.com', 'BOOKY');
            $mail->addAddress($email);

            $mail->Subject = $subject;
            $mail->isHTML(true);
            $mail->Body = $message;

            // Attach logo image
            $mail->addEmbeddedImage('images/booky2.png', 'booky_logo'); // Adjust path as needed

            if ($mail->send()) {
                echo "Verification code sent to your email. Check your inbox.";
                $_SESSION['email'] = $email;
                header("Location: verify_change_pass.php?email=$email");
                exit();
            } else {
                echo "Error sending verification code. Please try again later.";
            }
        } else {
            echo "Error updating verification code. Please try again later.";
        }
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["verify"])) {
    $email = $_SESSION['email'];
    $verification_code = $_POST['verification_code'];

    $check_code_sql = "SELECT user_id FROM user WHERE email_address = '$email' AND verification_code = '$verification_code'";
    $check_code_result = mysqli_query($conn, $check_code_sql);

    if (mysqli_num_rows($check_code_result) > 0) {
        $temporary_password = generateTemporaryPassword();
        $hashed_temporary_password = password_hash($temporary_password, PASSWORD_DEFAULT);
        $update_password_sql = "UPDATE user SET password = '$hashed_temporary_password' WHERE email_address = '$email'";

        if (mysqli_query($conn, $update_password_sql)) {
            sendTemporaryPasswordEmail($email, $temporary_password);
            header("Location: password_sent_success.php");
            exit();
        } else {
            echo "Error updating password. Please try again later.";
        }
    } else {
        echo "<script>alert('Invalid verification code. Please try again.'); history.go(-1);</script>";
    }
}

function generateTemporaryPassword($length = 8) {
    $characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $temporary_password = '';

    for ($i = 0; $i < $length; $i++) {
        $temporary_password .= $characters[rand(0, strlen($characters) - 1)];
    }

    return $temporary_password;
}

function sendTemporaryPasswordEmail($to, $temporary_password) {
    $subject = "Temporary Password for Password Reset";
    $message = '
        <html>
        <head>
            <style>
                .email-content {
                    font-family: Arial, sans-serif;
                    color: #333;
                    padding: 20px;
                    text-align:center;
                }

                .password {
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
                <img src="cid:booky_logo" class="logo" alt="Booky Logo" />
                <p style="font-weight:900;">Your new password is: <span class="password"><br>' . $temporary_password . '</span></p>
            </div>
        </body>
        </html>
    ';

    $mail = new PHPMailer();
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com'; // Replace with your SMTP server
    $mail->SMTPAuth = true;
    $mail->Username = 'jericobuncag0@gmail.com'; // Replace with your SMTP username
    $mail->Password = 'zswmpiantsrswvci'; // Replace with your SMTP password
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;

    $mail->setFrom('jericobuncag0@gmail.com', 'BOOKY');
    $mail->addAddress($to);

    $mail->Subject = $subject;
    $mail->isHTML(true);
    $mail->Body = $message;

    // Attach logo image
    $mail->addEmbeddedImage('images/booky2.png', 'booky_logo'); // Adjust path as needed

    if ($mail->send()) {
        echo "Temporary password sent to your email. Check your inbox.";
    } else {
        echo "Error sending temporary password. Please try again later.";
    }
}
?>
