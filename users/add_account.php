<?php include ("../header.php"); ?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New User</title>
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
            border-left: solid #E96529 10px;
            box-shadow: 0px 1px 5px 0px rgba(0, 0, 0, 0.33);
            width: 60%;
            margin-top: 70px;
            margin-left: auto;
            margin-right: auto;
            margin-bottom: 40px;
            background-color: #fff;
            border-radius: 10px;
            padding: 25px;
        }

        #First {
            box-shadow: 0px 1px 5px 0px rgba(0, 0, 0, 0.33);
        }

        .alert-container {
            position: fixed;
            top: 100px;
            right: 20px;
            transform: translateY(-50%);
            z-index: 1000;
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

        .spinner-border-sm {
        width: 1rem;
        height: 1rem;
        border-width: 0.2em;
    }
    </style>
</head>

<body>

    <div class="cont mt-5">
        <div id="content">
            <p style="font-weight:900;font-size:20px;color:#4BB0B8;">Add New User</p>
            <form action="add.php" method="POST">
                <div class="row">
                    <div class="col">
                        <div class="form-group mb-3">
                            <label for="name" style="font-weight:900;color:#6c6868;">
                                Name<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input type="text" style="padding:10px" class="form-control" id="name" name="name"
                                placeholder="Enter name" required maxlength="255">
                            <input type="hidden" value="<?php echo ($user_id); ?>" name="userId">
                        </div>
                        <div class="form-group mb-3">
                            <label for="email" style="font-weight:900;color:#6c6868;">
                                Email Address<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input type="email" class="form-control" id="email" name="emailAddress"
                                placeholder="Enter email address" style="padding:10px;" required maxlength="255">
                        </div>
                        <div class="form-group mb-3">
                            <label for="type" style="font-weight:900;color:#6c6868;">
                                Type<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select class="form-select" id="type" name="type" required style="padding:10px;">
                                <option selected disabled >-- Select User Type --</option>
                                <option value="User">User</option>
                                <option value="Admin">Admin</option>
                            </select>

                        </div>
                        <div class="mt-4 mb-2" style="text-align:right;">
                            <a href="index.php">
                                <button type="button" class="btn btn-danger clear" id="clearButton">Cancel</button>
                            </a>
                            <button type="submit" name="submit" class="btn btn-primary upload_file" id="submitButton">
                                <span>Submit</span>
                            </button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script>
    document.getElementById('submitButton').addEventListener('click', function(event) {
        event.preventDefault(); 

        const email = document.getElementById('email').value;
        const formData = new FormData(document.querySelector('form'));

        const submitButton = document.getElementById('submitButton');
        submitButton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Loading...'; // Add loading spinner
        submitButton.disabled = true; 

        const xhr = new XMLHttpRequest();
        xhr.open('POST', 'check_user.php', true); 
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                const response = xhr.responseText;
                if (response === 'exists') {
                    const alertContainer = document.createElement('div');
                    alertContainer.classList.add('alert-container', 'alert', 'alert-danger', 'mt-3');
                    alertContainer.setAttribute('role', 'alert');
                    alertContainer.innerHTML = '<i class="fa-solid fa-circle-check" style="padding-right:3px"></i> The email address you entered already exists. Please use a different email address.';
                    document.getElementById('content').appendChild(alertContainer);

                    setTimeout(function() {
                        alertContainer.classList.add('fade-out');
                        setTimeout(function() {
                            alertContainer.remove();
                        }, 1000); 
                    }, 5000);

                    submitButton.innerHTML = 'Submit';
                    submitButton.disabled = false;
                } else {
                    const formSubmit = new XMLHttpRequest();
                    formSubmit.open('POST', 'add.php', true);
                    formSubmit.onload = function() {
                        if (formSubmit.status === 200) {
                            window.location.href = 'index.php';
                        } else {
                            console.error('Error submitting form:', formSubmit.status);
                        }
                        submitButton.innerHTML = 'Submit';
                        submitButton.disabled = false;
                    };
                    formSubmit.send(formData);
                }
            } else {
                console.error('Error checking email:', xhr.status);
                submitButton.innerHTML = 'Submit';
                submitButton.disabled = false;
            }
        };
        xhr.send('email=' + encodeURIComponent(email));
    });
</script>
</body>
</html>
