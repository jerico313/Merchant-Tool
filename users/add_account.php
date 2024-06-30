<?php include ("../header.php") ?>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Homepage</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
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
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            background-attachment: fixed;
        }

        .title {
            font-size: 30px;
            font-weight: bold;
            margin-right: auto;
            padding-left: 5vh;
            color: #E96529;
        }

        .back {
            font-size: 20px;
            font-weight: bold;
            margin-right: auto;
            padding-left: 5vh;
            color: #E96529;
        }

        .add-btns {
            padding-bottom: 0px;
            padding-right: 5vh;
            display: flex;
            align-items: center;
        }

        .table-transparent {
            border: solid 1px lightgrey;
            radius: 10px;
        }

        .loading {
            display: none;
        }

        .alert-custom, .alert-custom-filename, .alert-custom-filetype {
            display: none;
            position: fixed;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            z-index: 1000;
            margin-top: 70px;
            width: 99%;
            padding: 15px;
            font-size: 13px;
        }

        .file-preview {
            overflow-x: auto;
            margin-left: auto;
            margin-right: auto;
        }

    </style>
</head>
<body>

<div class="cont-box">
    <div class="custom-box pt-4">
    <div><a href="javascript:history.back()"><span class="back"><i class="fa-regular fa-circle-left fa-lg"></i><span style="font-size:17px;color:grey;cursor:pointer;"> Back to Manage Users</span></span></a>
        <div class="upload pt-3" style="text-align:left;">
            <div class="add-btns">
                <p class="title">Create a New Account</p>
                <form id="uploadForm" action="upload_process.php" method="post" enctype="multipart/form-data">
            </div>
        </div>
    </div>
</div>
<div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
            <form id="dynamic-form"
                        action="add.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                        method="POST">
                        <div id="form-fields">
                            <div class="form-group">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="store_id" class="form-label"
                                                style="font-size:15px;font-weight:bold;">Email Address</label>
                                            <input type="text" class="form-control" name="store_id[]"
                                                style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="merchant_name" class="form-label"
                                                style="font-size:15px;font-weight:bold;">Name</label>
                                            <input type="text" class="form-control"                
                                                name="merchant_name[]"
                                                style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;"
                                                required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="store_name" class="form-label"
                                                style="font-size:15px;font-weight:bold;">User Type</label>
                                                <select class="form-select" id="reportType" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                                    <option selected disabled>-- Select User Type --</option>
                                                    <option value="Admin">Admin</option>
                                                    <option value="User">User</option>
                                                </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="legal_entity_name" class="form-label"
                                                style="font-size:15px;font-weight:bold;">Password</label>
                                            <input type="password" class="form-control" name="legal_entity_name[]"
                                                style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="store_address" class="form-label"
                                                style="font-size:15px;font-weight:bold;">Confirm Password</label>
                                            <input type="password" class="form-control" name="store_address[]"
                                                style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                        </div>
                                    </div>
                                    <div class="mb-3 mt-3" style="text-align:right;">

                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="" style="text-align:right;margin:10px 0px;">
                            <button type="submit" class="check-report">Submit</button>
                        </div>
                    </form>
            </div>
        </div>
    </div>
</div>

</body>
</html>
