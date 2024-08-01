<?php include("../header.php");?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/papaparse@5.3.0/papaparse.min.js"></script>
    <link rel="stylesheet" href="../style.css">
    <style>
        body {
            background-image: url("../images/bg_booky.png");    
        }

        #content {
            border-left: solid #E96529 8px;
            box-shadow: 0px 1px 5px 0px rgba(0,0,0,0.33);
            width: 95%;
            margin-left: auto;
            margin-right: auto;
            margin-bottom: 40px; 
            background-color: #fff;
            border-radius: 10px;
            padding: 10px;
        }

        #First {
            box-shadow: 0px 1px 5px 0px rgba(0,0,0,0.33);
        }
    </style>
</head>
<body>
<div class="mt-4 mb-3">
    <a href="javascript:history.back()">
        <span class="back">
            <i class="fa-regular fa-circle-left fa-lg"></i>
            <span class="back-text"> Back to Manage Users</span>
        </span>
    </a>
</div>
<div class="cont-box">
    <div id="content">
        <div class="name" style="margin-left:10px;">
            <p style="font-weight:900;font-size:20px;color:#4BB0B8;">Create a New Account</p>
        </div>
        <form action="add.php"  method="POST">
            <div id="First" style="padding:20px !important;margin:10px;border-radius:8px;border-left:solid #E96529 8px;padding:5px;">
                <div class="row">
                    <div class="col-md-6 pb-3">
                        <div class="form-group mb-3">
                            <label for="name" style="font-weight:900;color:#6c6868;">Name<span class="text-danger" style="padding:2px">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" style="font-weight:700;">
                            <input type="hidden" value="<?php echo ($user_id); ?>" name="userId">
                        </div>
                        <div class="form-group mb-3">
                            <label for="email" style="font-weight:900;color:#6c6868;">Email<span class="text-danger" style="padding:2px">*</span></label>
                            <input type="email" class="form-control" id="email" name="emailAddress" style="font-weight:700;">
                        </div>
                        <div class="form-group mb-3">
                            <label for="type" style="font-weight:900;color:#6c6868;">Type<span class="text-danger" style="padding:2px">*</span></label>
                            <select class="form-select" id="type" name="type" required>
                                <option selected disabled value="">-- Select User Type --</option>
                                <option value="User">User</option>
                                <option value="Admin">Admin</option>
                            </select>
                            
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label for="department" style="font-weight:900;color:#6c6868;">Department<span class="text-danger" style="padding:2px">*</span></label>
                            <select class="form-select" id="department" name="department" required>
                                <option selected disabled value="">-- Select Department --</option>
                                <option value="Admin">Admin</option>
                                <option value="Operations">Operations</option>
                                <option value="Finance">Finance</option>
                            </select>
                        </div>
                        <div class="form-group mb-3">
                            <label for="password" style="font-weight:900;color:#6c6868;">Password<span class="text-danger" style="padding:2px">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="password" name="password" style="font-weight:700;">
                                <span class="input-group-text">
                                    <i class="fas fa-eye" id="togglePassword" style="cursor: pointer;"></i>
                                </span>
                            </div>
                        </div>
                        <div class="form-group mt-3">
                            <label for="confirmPassword" style="font-weight:900;color:#6c6868;">Confirm Password<span class="text-danger" style="padding:2px">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" style="font-weight:700;">
                                <span class="input-group-text">
                                    <i class="fas fa-eye" id="toggleConfirmPassword" style="cursor: pointer;"></i>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="text-right" style="text-align:right;margin-right:10px;">
                        <button type="button" id="generatePasswordButton" onclick="generatePassword()" class="btn btn-primary" style="background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px; display: none;">Generate Password</button>
                    </div>
                </div>
            </div>
            <div class="mt-4 mb-2" style="text-align:right;margin-right:10px;">
                <button type="submit" name="submit" class="btn btn-primary" style="background-color:#4BB0B8;border:#4BB0B8;border-radius: 20px;">Submit</button>
            </div>
        </f>
    </div>
</div>

<script>
function generatePassword() {
    var name = document.getElementById('name').value.trim();
    var email = document.getElementById('email').value.trim();
    var type = document.getElementById('type').value;
    var department = document.getElementById('department').value;

    if (!name || !email || !type || !department) {
        alert('Please fill in all fields before generating a password.');
        return;
    }

    var sanitizedName = name.replace(/\s+/g, '_');
    var sanitizedDepartment;

    switch(department) {
        case 'Operations':
            sanitizedDepartment = 'Ops';
            break;
        case 'Finance':
            sanitizedDepartment = 'Fin';
            break;
        case 'Admin':
            sanitizedDepartment = 'Adm';
            break;
        default:
            sanitizedDepartment = department.replace(/\s+/g, '_');
    }

    var randomNumber = Math.floor(Math.random() * 1000);
    var password = sanitizedName + '_' + sanitizedDepartment + randomNumber;

    document.getElementById('password').value = password;
    document.getElementById('confirmPassword').value = password;
}

function toggleGeneratePasswordButton() {
    var name = document.getElementById('name').value.trim();
    var email = document.getElementById('email').value.trim();
    var type = document.getElementById('type').value;
    var department = document.getElementById('department').value;

    var generateButton = document.getElementById('generatePasswordButton');
    if (name && email && type && department) {
        generateButton.style.display = 'inline-block';
    } else {
        generateButton.style.display = 'none';
    }
}

document.getElementById('name').addEventListener('input', toggleGeneratePasswordButton);
document.getElementById('email').addEventListener('input', toggleGeneratePasswordButton);
document.getElementById('type').addEventListener('change', toggleGeneratePasswordButton);
document.getElementById('department').addEventListener('change', toggleGeneratePasswordButton);

document.addEventListener('DOMContentLoaded', toggleGeneratePasswordButton);

function togglePasswordVisibility(inputId, iconId) {
    const passwordField = document.getElementById(inputId);
    const toggleIcon = document.getElementById(iconId);
    if (passwordField.type === 'password') {
        passwordField.type = 'text';
        toggleIcon.classList.remove('fa-eye');
        toggleIcon.classList.add('fa-eye-slash');
    } else {
        passwordField.type = 'password';
        toggleIcon.classList.remove('fa-eye-slash');
        toggleIcon.classList.add('fa-eye');
    }
}

document.getElementById('togglePassword').addEventListener('click', function() {
    togglePasswordVisibility('password', 'togglePassword');
});
document.getElementById('toggleConfirmPassword').addEventListener('click', function() {
    togglePasswordVisibility('confirmPassword', 'toggleConfirmPassword');
});
</script>

</body>
</html>
