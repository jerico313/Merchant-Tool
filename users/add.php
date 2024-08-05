<?php
include("../inc/config.php");
require '../Mailer/vendor/autoload.php'; // Include Composer autoloader

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Function to generate a random password
function generateRandomPassword($length = 10) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomPassword = '';
    for ($i = 0; $i < $length; $i++) {
        $randomPassword .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomPassword;
}

// Function to send email
function sendEmail($to, $subject, $message) {
    $mail = new PHPMailer();
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com'; // Replace with your SMTP server
    $mail->SMTPAuth = true;
    $mail->Username = 'jericobuncag0@gmail.com'; // Replace with your SMTP username
    $mail->Password = 'zswmpiantsrswvci'; // Replace with your SMTP password
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;

    $mail->setFrom('jericobuncag0@gmail.com', 'Booky'); // Replace with your email and name
    $mail->addAddress($to);
    
    $mail->Subject = $subject;
    $mail->isHTML(true);
    $mail->Body = $message;
    $mail->addEmbeddedImage('../images/booky2.png', 'booky_logo'); // Adjust path as needed
    return $mail->send();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Retrieve POST data
    $name = $_POST['name'];
    $emailAddress = $_POST['emailAddress'];
    $type = $_POST['type'];
    $user_id = $_POST['userId'];

    // Check if the email already exists
    $stmt = $conn->prepare("SELECT COUNT(*) FROM user WHERE email_address = ?");
    $stmt->bind_param("s", $emailAddress);
    $stmt->execute();
    $stmt->bind_result($emailCount);
    $stmt->fetch();
    $stmt->close();

    if ($emailCount > 0) {
        // Email already exists
        echo "Error: The email address is already registered.";
    } else {
        // Generate random password
        $randomPassword = generateRandomPassword();
        // Hash the password before storing in the database
        $hashedPassword = password_hash($randomPassword, PASSWORD_BCRYPT);

        // Prepare and execute the insert statement
        $stmt = $conn->prepare("INSERT INTO user (name, email_address, type, password) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $name, $emailAddress, $type, $hashedPassword);
        $stmt->execute();
        $stmt->close();

        // Get the latest activity_id
        $stmt = $conn->prepare("SELECT activity_id FROM activity_history ORDER BY created_at DESC LIMIT 1");
        if ($stmt->execute()) {
            $stmt->bind_result($latestActivityId);
            $stmt->fetch();
            $stmt->close();

            // Update the user_id column in the latest activity_history record
            if ($latestActivityId) {
                $stmt = $conn->prepare("UPDATE activity_history SET user_id=? WHERE activity_id=?");
                $stmt->bind_param("ss", $user_id, $latestActivityId);
                $stmt->execute();
                $stmt->close();
            }
        }

        // Prepare email content
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

        // Send the email
        if (sendEmail($emailAddress, $subject, $message)) {
            echo "Success: The account has been created, and the password has been sent to the provided email address.";
        } else {
            echo "Error: Failed to send the email.";
        }

        // Redirect to the same page after a successful update
        header("Location: index.php");
        exit();
    }
}

$conn->close();
?>
