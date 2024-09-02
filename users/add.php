<?php
include("../inc/config.php");
require '../Mailer/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

function generateRandomPassword($length = 10) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomPassword = '';
    for ($i = 0; $i < $length; $i++) {
        $randomPassword .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomPassword;
}

function sendEmail($to, $subject, $message) {
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
    $mail->addEmbeddedImage('../images/booky2.png', 'booky_logo');
    return $mail->send();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'];
    $emailAddress = $_POST['emailAddress'];
    $type = $_POST['type'];
    $user_id = $_POST['userId'];

    $stmt = $conn->prepare("SELECT COUNT(*) FROM user WHERE email_address = ?");
    $stmt->bind_param("s", $emailAddress);
    $stmt->execute();
    $stmt->bind_result($emailCount);
    $stmt->fetch();
    $stmt->close();

    if ($emailCount > 0) {
        echo "Error: The email address is already registered.";
    } else {
        $randomPassword = generateRandomPassword();
        $hashedPassword = password_hash($randomPassword, PASSWORD_BCRYPT);

        $stmt = $conn->prepare("INSERT INTO user (name, email_address, type, password) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $name, $emailAddress, $type, $hashedPassword);
        $stmt->execute();
        $stmt->close();

        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt->execute()) {
            $stmt->bind_result($latestActivityId);
            $stmt->fetch();
            $stmt->close();

            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
                $stmt->bind_param("ss", $user_id, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }
        }

        $subject = "Welcome to Merchant Settlement Tool";
        $message = '
            <html>
            <head>
                <style>
                    .email-content {
                        font-family: Arial, sans-serif;
                        color: black;
                        padding: 20px;
                    }
                    .password {
                        color: #E96529;
                        font-weight: bold;
                    }

                    .email {
                        color: #E96529 !important;
                        font-weight: bold;
                    }

                    .emailAdd{
                        font-family: Arial, sans-serif;
                        color: black;
                    }
                    .logo {
                            width: 150px;
                        }

                        .booky_logo {
                            text-align:center;
                        }
                </style>
            </head>
            <body>
                <div class="email-content">
                    <div class="booky_logo">
                    <img src="cid:booky_logo" class="logo" alt="Booky Logo" />
                    </div>
                    <p>Hi ' . htmlspecialchars($name) . ',</p>
                    <p>Have a nice day and welcome to Merchant Settlement Tool!<p>
                    <p>Please see your access and Credentials attached to this email.</p>
                    <div class="emailAdd">
                    <p style="font-weight:bold;">Email:<br><span style="color:#E96529 !important;">'.htmlspecialchars($emailAddress).'</span></p>
                    <p style="font-weight:bold;">Password:<br><span class="password">' . htmlspecialchars($randomPassword) . '</span></p>
                    <p style="font-weight:bold;">Sign in at the link below:<br><span style="color:#E96529 !important;">https://merchant-settlement-tool.com</span></p>
                    </div>
                </div>
            </body>
            </html>
        ';

        if (sendEmail($emailAddress, $subject, $message)) {
            echo "Success: The account has been created, and the password has been sent to the provided email address.";
        } else {
            echo "Error: Failed to send the email.";
        }

        header("Location: index.php");
        exit();
    }
}

$conn->close();
?>
