<?php include("header.php")?>
<!DOCTYPE html>
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
    <link rel="stylesheet" href="style.css">
    <style>
        body {
            background-image: url("images/bg_booky.png");
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

        .alert-custom {
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

        .or {
            width: 100%;
            text-align: center;
            border-bottom: 1px solid #000;
            line-height: 0.1em;
            margin: 10px 0 20px;
        }

        .table-container {
            overflow-x: auto;
            margin-left: auto;
            margin-right: auto;
        }
        
        hr {
            border: 0;
            height: 1px;
            background-image: linear-gradient(to right, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.75), rgba(0, 0, 0, 0));
        }
    </style>
</head>
<body>

<div class="cont-box">
    <div class="custom-box pt-4">
        <a href="merchant.php">
            <p class="back"><i class="fa-regular fa-circle-left fa-lg"></i></p>
        </a>
        <div class="upload" style="text-align:left;">
            <div class="add-btns">
                <p class="title">Upload Merchants</p>
                <button type="button" class="btn btn-warning check-report" id="addMerchantBtn"><i class="fa-solid fa-plus"></i> Add New Merchant </button>
                <form id="uploadForm" action="upload_merchant_process.php" method="post" enctype="multipart/form-data">
            </div>

            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <div class="file" style="padding:10px 10px 10px 0;font-size:15px;">
                    <p style="font-weight:bold;">Selected File: <span class="filename" style="color:#E96529"></span></p>
                </div>
                <label for="fileToUpload" style="background-color:#fff;font-size:20px;" class="upload-btn"
                       id="uploadBtn"><i class="fa-solid fa-cloud-arrow-up fa-2xl"
                                         style="font-size:40px;padding-bottom:30px;"></i><br>Choose a File or Drag it
                    here </label>
                <input type="file" name="fileToUpload" id="fileToUpload" accept=".csv" style="display:none;">
                <div class="uploadfile" style="text-align:right;">
                    <button type="submit" class="btn btn-secondary upload_file" id="submitButton">Submit</button>
                    <div class="loading" id="loadingIndicator"><i class="fas fa-spinner fa-spin"></i> Loading...
                    </div>
                </div>
                <div class="file-preview" style="margin-top:20px;">
                    <div class="table-container">
                        <!-- Table will be appended here -->
                    </div>
                </div>
                </form>
            </div>
        </div>

        <div class="form" style="text-align:left;display:none;">
            <div class="add-btns">
                <p class="title">Merchant Details</p>
                <button type="button" class="btn btn-warning check-report" id="uploadMerchantBtn"><i class="fa-solid fa-upload"></i> Upload Merchants </button>
                <button type="button" class="btn btn-success" id="add-field"><i class="fa-solid fa-plus"></i> Add More </button>
            </div>

            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
            <form id="dynamic-form" action="add_merchant.php" method="POST">
                <div id="form-fields">
                    <div class="form-group">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="merchant_id" class="form-label" style="font-size:15px;font-weight:bold;">Merchant ID</label>
                                    <input type="text" class="form-control" name="merchant_id[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_name" class="form-label" style="font-size:15px;font-weight:bold;">Merchant Name</label>
                                    <input type="text" class="form-control" name="merchant_name[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_type" class="form-label" style="font-size:15px;font-weight:bold;">Merchant Type</label>
                                    <select class="form-select" id="merchant_type" name="merchant_type[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Merchant Type --</option>
                                        <option value="Primary">Primary</option>
                                        <option value="Secondary">Secondary</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="business_address" class="form-label" style="font-size:15px;font-weight:bold;">Business Address</label>
                                    <input type="text" class="form-control" name="business_address[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="email_address" class="form-label" style="font-size:15px;font-weight:bold;">Email Address</label>
                                    <input type="text" class="form-control" name="email_address[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                            </div>
                            <div class="mb-3" style="text-align:right;">
                                <button type="button" class="btn btn-danger remove-field">Remove</button>
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

<div class="alert-custom alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
    <i class="fa-solid fa-circle-exclamation"></i> Please choose a file to upload!
</div>
<script src="./js/file_upload.js"></script>
<script>
    // Add event listeners to buttons
    document.getElementById('addMerchantBtn').addEventListener('click', function () {
        document.querySelector('.form').style.display = 'block';
        document.querySelector('.upload').style.display = 'none';
    });

    document.getElementById('uploadMerchantBtn').addEventListener('click', function () {
        document.querySelector('.form').style.display = 'none';
        document.querySelector('.upload').style.display = 'block';
    });

    document.addEventListener("DOMContentLoaded", function() {
        // Trigger input event to generate form for default value
        document.getElementById('MerchantNum').dispatchEvent(new Event('input'));
    });

    document.getElementById('add-field').addEventListener('click', function() {
        var formFields = document.getElementById('form-fields');
        var newField = document.createElement('div');
        newField.classList.add('form-group');
        newField.innerHTML = `
        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="merchant_id" class="form-label" style="font-size:15px;font-weight:bold;">Merchant ID</label>
                                    <input type="text" class="form-control" name="merchant_id[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_name" class="form-label" style="font-size:15px;font-weight:bold;">Merchant Name</label>
                                    <input type="text" class="form-control" name="merchant_name[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_type" class="form-label" style="font-size:15px;font-weight:bold;">Merchant Type</label>
                                    <select class="form-select" id="merchant_type" name="merchant_type[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Merchant Type --</option>
                                        <option value="Primary">Primary</option>
                                        <option value="Secondary">Secondary</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="business_address" class="form-label" style="font-size:15px;font-weight:bold;">Business Address</label>
                                    <input type="text" class="form-control" name="business_address[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="email_address" class="form-label" style="font-size:15px;font-weight:bold;">Email Address</label>
                                    <input type="text" class="form-control" name="email_address[]" style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                            </div>
                            <div class="mb-3" style="text-align:right;">
                                <button type="button" class="btn btn-danger remove-field">Remove</button>
                            </div>
                        </div>
        `;
        formFields.appendChild(newField);
    });

    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('remove-field')) {
            e.target.closest('.form-group').remove();
        }
    });
</script>
</body>
</html>
