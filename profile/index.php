<?php 
include ("../header.php"); 
include ("../inc/config.php");

$user_id = $_SESSION['user_id'];
$sql = "SELECT * FROM user WHERE user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();
$data = $result->fetch_assoc();
$stmt->close();

$alert = ''; 

if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['change_password'])) {
    $old_password = $_POST['old_password'];
    $new_password = $_POST['new_password'];
    $confirm_password = $_POST['confirm_password'];

    $sql = "SELECT password FROM user WHERE user_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();
    $stmt->close();

    if (password_verify($old_password, $user['password'])) {
        if ($new_password == $confirm_password) {
            $new_password_hashed = password_hash($new_password, PASSWORD_DEFAULT);
            $sql = "UPDATE user SET password = ? WHERE user_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("ss", $new_password_hashed, $user_id);
            if ($stmt->execute()) {
                $alert = '<div id="alert-message" class="alert alert-success" role="alert">Password changed successfully!</div>';
            } else {
                $alert = '<div id="alert-message" class="alert alert-danger" role="alert">Password change failed!</div>';
            }
            $stmt->close();
        } else {
            $alert = '<div id="alert-message" class="alert alert-danger" role="alert">New passwords do not match!</div>';
        }
    } else {
        $alert = '<div id="alert-message" class="alert alert-danger" role="alert">Old password is incorrect!</div>';
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/papaparse@5.3.0/papaparse.min.js"></script>
    <link rel="stylesheet" href="../style.css">
    <style>
        body {
            background-image: url("../images/bg_booky.png");            
        }

        .content, #First {
            box-shadow: 0px 1px 5px 0px rgba(0,0,0,0.33);
            -webkit-box-shadow: 0px 1px 5px 0px rgba(0,0,0,0.33);
            -moz-box-shadow: 0px 1px 5px 0px rgba(0,0,0,0.33);
        }

        .nav-tabs .nav-link.active{
            color: #E96529;
            font-weight: 800;
            border-color: transparent ;
            border-top-left-radius:10px;
            border-top-right-radius:10px;
        }

        .nav-tabs .nav-link{
            color: #fff;
            font-weight: 800;
            border-top-left-radius:10px;
            border-top-right-radius:10px;
        }

        .alert-success, .alert-danger {
            position: fixed;
            top: 0;
            left: 85%;
            transform: translateX(-50%);
            z-index: 1000;
            margin-top: 70px;
            width: 25%;
            padding: 15px;
            font-size: 13px;
        }
    </style>
</head>

<body>
    <div class="cont">
        <div class="custom-box pt-2">
            <div class="upload pt-3" style="text-align:left;">
                <div class="add-btns">
                    <p class="title"><i class="fa-solid fa-user fa-sm"></i> Profile</p>
                </div>

                <div class="content"
                    style="width:95%;margin-left:auto;margin-right:auto;margin-bottom:40px; background-color:#fff;border-radius:10px;padding:5px;">
                    <div class="nav" style="margin:-5px;padding:8px;background-color: #E96529;border-top-right-radius:8px;border-top-left-radius:8px;height:39px;">
                    <ul class="nav nav-tabs" id="exampleTab" role="tablist">
                        <li class="nav-item">
                            <a class="nav-link active" id="exampleFirstTab" data-toggle="tab" href="#exampleFirst"
                                role="tab" aria-controls="exampleFirst" aria-selected="true">Edit Profile</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="exampleSecondTab" data-toggle="tab" href="#exampleSecond"
                                role="tab" aria-controls="exampleSecond" aria-selected="false">Change Password</a>
                        </li>
                    </ul>
                    </div>
                    <div class="tab-content py-3" id="exampleTabContent">
                        <?php echo $alert; // Display the alert ?>
                        <div class="tab-pane fade show active" id="exampleFirst" role="tabpanel"
                            aria-labelledby="exampleFirstTab">
                            <form method="POST" action="update.php">
                                <div style="padding:10px !important;margin:10px;">
                                    <p style="font-weight:900;font-size:20px;color:#4BB0B8;"><?php echo strtoupper($data['name']); ?> (<?php echo htmlspecialchars($data['user_id']); ?>)</p>
                                    <hr style="border: 1px solid #3b3b3b;">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group mb-3">
                                                <label for="name" style="font-weight:900;color:#6c6868;">Name</label>
                                                <input type="text" class="form-control" id="name" style="font-weight:700;" name="name" placeholder="Enter name" value="<?php echo htmlspecialchars($data['name']); ?>" required maxlength="255">
                                                <input type="hidden" class="form-control" id="user_id" name="user_id" value="<?php echo htmlspecialchars($data['user_id']); ?>">
                                            </div>
                                            <div class="form-group mb-3">
                                                <label for="email" style="font-weight:900;color:#6c6868;">Email Address</label>
                                                <input type="email" class="form-control" id="email" style="font-weight:700;" name="email" placeholder="Enter email address" value="<?php echo htmlspecialchars($data['email_address']); ?>" required maxlength="255">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group mb-3">
                                                <label for="type" style="font-weight:900;color:#6c6868;">Type</label>
                                                <p style="border:none;padding:0px;font-weight:700;" class="form-control mt-2" id="type"><?php echo htmlspecialchars($data['type']); ?></p>
                                            </div>
                                            <div class="form-group mb-3">
                                                <label for="status" style="font-weight:900;color:#6c6868;">Status</label>
                                                <p style="border:none;padding:0px;font-weight:700; color: <?php echo ($data['status'] == 'Active') ? 'green' : 'red'; ?>" 
                                                    class="form-control mt-2" 
                                                    id="status"> <?php echo htmlspecialchars($data['status']); ?></p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div style="text-align:right;margin-right:10px;">
                                    <button type="submit" name="update_profile" class="btn btn-primary upload_file" id="submitButton">
                                        <span>Save changes</span>
                                    </button>
                                </div>
                            </form>
                        </div>

                        <div class="tab-pane fade" id="exampleSecond" role="tabpanel"
                            aria-labelledby="exampleSecondTab">
                            <form method="POST">
                                <div style="padding:10px !important;margin:10px;">
                                    <p style="font-weight:900;font-size:20px;color:#4BB0B8;"><?php echo strtoupper($data['name']); ?> (<?php echo htmlspecialchars($data['user_id']); ?>)</p>
                                    <hr style="border: 1px solid #3b3b3b;">
                                    <div class="col-md-6">
                                        <div class="form-group mb-3">
                                            <label for="old_password" style="font-weight:900;color:#6c6868;">Old Password</label>
                                            <div class="input-group">
                                                <input type="password" class="form-control" id="old_password" name="old_password" placeholder="Enter old password">
                                                <span class="input-group-text"><i class="fa fa-key"></i></span>
                                            </div>
                                        </div>
                                        <div class="form-group mb-3">
                                            <label for="new_password" style="font-weight:900;color:#6c6868;">New Password</label>
                                            <div class="input-group">
                                                <input type="password" class="form-control" id="new_password" name="new_password" placeholder="Enter new password">
                                                <span class="input-group-text"><i class="fa fa-key"></i></span>
                                            </div>
                                        </div>
                                        <div class="form-group mb-3">
                                            <label for="confirm_password" style="font-weight:900;color:#6c6868;">Confirm Password</label>
                                            <div class="input-group">
                                                <input type="password" class="form-control" id="confirm_password" name="confirm_password" placeholder="Confirm new password">
                                                <span class="input-group-text"><i class="fa fa-key"></i></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div style="text-align:right;margin-right:10px;">
                                    <button type="submit" name="change_password" class="btn btn-primary upload_file" id="submitButton">
                                        <span>Save changes</span>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"
            integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj"
            crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"
            integrity="sha384-Fy6S3B9q64WdZWQUiU+q4/2Lc9npb8tCaSX9FK7E8HnRr0Jz8D6OP9dO5Vg3Q9ct"
            crossorigin="anonymous"></script>

        <script>
    setTimeout(function(){
        var alertMessage = document.getElementById('alert-message');
        if(alertMessage){
            alertMessage.remove();
        }
    }, 3000); 
</script>
</body>

</html>
