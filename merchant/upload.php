<?php include ("../header.php") ?>
<?php
function fetchSales() {
    include("../inc/config.php");

    // Updated SQL query to filter by department
    $employeeSql = "SELECT user_id, name FROM user WHERE department = 'Finance' ORDER BY name";
    $employeeResult = $conn->query($employeeSql);

    if ($employeeResult->num_rows > 0) {
        echo "<option value=''>No assigned person</option>";
        while ($employeeRow = $employeeResult->fetch_assoc()) {
            echo "<option value='" . htmlspecialchars($employeeRow['user_id'], ENT_QUOTES, 'UTF-8') . "'>" . htmlspecialchars($employeeRow['name'], ENT_QUOTES, 'UTF-8') . "</option>";
        }
    } else {
        echo "<option value=''>No users found</option>";
    }
}

function fetchAccountManager() {
    include("../inc/config.php");

    // Updated SQL query to filter by department
    $employeeSql = "SELECT user_id, name FROM user WHERE department = 'Operations' ORDER BY name";
    $employeeResult = $conn->query($employeeSql);

    if ($employeeResult->num_rows > 0) {
        echo "<option value=''>No assigned person</option>";
        while ($employeeRow = $employeeResult->fetch_assoc()) {
            echo "<option value='" . htmlspecialchars($employeeRow['user_id'], ENT_QUOTES, 'UTF-8') . "'>" . htmlspecialchars($employeeRow['name'], ENT_QUOTES, 'UTF-8') . "</option>";
        }
    } else {
        echo "<option value=''>No users found</option>";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Merchants</title>
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
            right: 20px;
            transform: translateY(-50%);
            z-index: 1000;
            margin-top: 105px;
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
            border-left:solid 3px #f01e2c;
            box-sizing: border-box;
        }

        /* Animation for fading in and out */
        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        @keyframes fadeOut {
            from {
                opacity: 1;
            }
            to {
                opacity: 0;
            }
        }

        @keyframes shake {
            0%, 100% {
                transform: translateX(0) translateY(-50%);
            }
            10%, 30%, 50%, 70%, 90% {
                transform: translateX(-10px) translateY(-50%);
            }
            20%, 40%, 60%, 80% {
                transform: translateX(10px) translateY(-50%);
            }
        }

        .alert-custom, .alert-custom-filename, .alert-custom-filetype {
            animation: fadeIn 0.5s ease-in-out, shake 0.4s ease-in-out;
        }

        .alert-custom.hide, .alert-custom-filename.hide, .alert-custom-filetype.hide {
            animation: fadeOut 0.5s ease-in-out;
            animation-fill-mode: forwards;
        }

        .file-preview {
            overflow-x: auto;
            margin-left: auto;
            margin-right: auto;
        }

        #input-label {
            font-size: 15px;
            font-weight: 700;
        }

        #input-field{
            font-size: 13px;
            font-weight: 600;
            border-radius: 5px;
            padding:10px 20px;
            border: 1px dashed #928a89;
        }
    </style>
</head>
<body>
    <div class="cont-box">
        <div class="custom-box pt-4">
            <a href="javascript:history.back()">
                <span class="back">
                    <i class="fa-regular fa-circle-left fa-sm"></i>
                    <span style="font-size:15px;color:grey;cursor:pointer;padding-left:3px"> Back to Merchants</span>
                </span>
            </a>
            <div class="upload pt-4" style="text-align:left;">
                <form id="uploadForm" action="upload_process.php" method="post" enctype="multipart/form-data">
                <div class="add-btns">
                    <p class="title">Upload Merchants</p>
                    <button type="button" class="btn btn-warning check-report" id="addMerchantBtn">
                        <i class="fa-solid fa-plus"></i> Add New Merchant 
                    </button>
                </div>

                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <div class="file" style="padding:10px 10px 10px 0;font-size:15px;">
                        <p style="font-weight:bold;">Selected File: <span class="filename" style="color:#E96529"></span></p>
                    </div>
                    <label for="fileToUpload" style="background-color:#fff;font-size:20px;" class="upload-btn" id="uploadBtn">
                        <i class="fa-solid fa-cloud-arrow-up fa-2xl" style="font-size:40px;padding-bottom:30px;"></i>
                        <br>Choose a File
                    </label>
                    <input type="file" name="fileToUpload" id="fileToUpload" accept=".csv" style="display:none;">
                    <div class="uploadfile" style="text-align:right;">
                        <button type="button" class="btn btn-danger clear" id="clearButton">Clear</button>
                        <button type="submit" class="btn btn-secondary upload_file" id="submitButton"><span>Submit</span></button>
                    </div>
                    <div class="file-preview" style="margin-top:20px;">
                        <div class="table-container">
                            <!-- Table will be appended here -->
                        </div>
                    </div>
                </div>
                </form>
            </div>

            <div class="form" style="text-align:left;display:none;">
                <div class="add-btns pt-4">
                    <p class="title">Merchant Details</p>
                    <button type="button" class="btn btn-warning check-report" id="uploadMerchantBtn"><i class="fa-solid fa-upload"></i> Upload Merchants </button>
                    <button type="button" class="btn btn-success" id="add-field"><i class="fa-solid fa-plus"></i> Add More </button>
                </div>

                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
    <form id="dynamic-form" action="add.php" method="POST">
        <div id="form-fields">
            <div class="form-group">
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="merchant_id" class="form-label" id="input-label">
                                Merchant ID<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="input-field" type="text" class="form-control" name="merchant_id[]" placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" required maxlength="36">
                        </div>
                        <div class="mb-3">
                            <label for="merchant_name" class="form-label" id="input-label">
                                Merchant Name<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="input-field" type="text" class="form-control" name="merchant_name[]" placeholder="Enter merchant name" required maxlength="255">
                        </div>
                        <div class="mb-3">
                            <label for="merchantParntershipType" class="form-label" id="input-label">
                                Partnership Type<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="input-field" class="form-select" name="merchantParntershipType[]" required>
                                <option value="" disabled selected>-- Select Partnership Type --</option>
                                <option value="Primary">Primary</option>
                                <option value="Secondary">Secondary</option>
                                <option value="">Unknown Partnership Type</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="legal_entity_name" class="form-label" id="input-label">Legal Entity Name</label>
                            <input id="input-field" type="text" class="form-control" name="legal_entity_name[]" placeholder="Enter legal entity name" maxlength="255">
                        </div>
                        <div class="mb-3">
                            <label for="business_address" class="form-label" id="input-label">Business Address</label>
                            <input id="input-field" type="text" class="form-control" name="business_address[]" placeholder="Enter business address">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="email_address" class="form-label" id="input-label">Email Address</label>
                            <textarea id="input-field" class="form-control pb-3 pt-3" rows="5" name="email_address[]" placeholder="Enter email address"></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="sales" class="form-label" id="input-label">
                                Sales<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="input-field" class="form-select" name="sales[]" required>
                                <option value="" disabled selected>-- Select Sales --</option>
                                <?php fetchSales(); ?>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="account_manager" class="form-label" id="input-label">
                                Account Manager<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="input-field" class="form-select" name="account_manager[]" required>
                                <option value="" disabled selected>-- Select Account Manager --</option>
                                <?php fetchAccountManager(); ?>
                            </select>
                        </div>
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

    <div class="alert-custom alert alert-danger" role="alert">
        <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Please choose a file to upload!
    </div>

    <div class="alert-custom-filename alert alert-danger" role="alert">
        <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Please upload the correct file named "Merchant Listing.csv" !
    </div>

    <div class="alert-custom-filetype alert alert-danger" role="alert">
        <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Please upload a file with .csv extension only!
    </div>

    <script>
        document.getElementById('addMerchantBtn').addEventListener('click', function () {
            document.querySelector('.form').style.display = 'block';
            document.querySelector('.upload').style.display = 'none';
        });

        document.getElementById('uploadMerchantBtn').addEventListener('click', function () {
            document.querySelector('.form').style.display = 'none';
            document.querySelector('.upload').style.display = 'block';
        });

        document.addEventListener("DOMContentLoaded", function() {
            document.getElementById('MerchantNum').dispatchEvent(new Event('input'));
        });

        document.getElementById('add-field').addEventListener('click', function() {
            var formFields = document.getElementById('form-fields');
            var newField = document.createElement('div');
            newField.classList.add('form-group');
            newField.innerHTML = `
                <div class="row">
                <hr style="border: 1px solid #3b3b3b;">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="merchant_id" class="form-label" id="input-label">
                                Merchant ID<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="input-field" type="text" class="form-control" name="merchant_id[]" placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" required maxlength="36">
                        </div>
                        <div class="mb-3">
                            <label for="merchant_name" class="form-label" id="input-label">
                                Merchant Name<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="input-field" type="text" class="form-control" name="merchant_name[]" placeholder="Enter merchant name" required maxlength="255">
                        </div>
                        <div class="mb-3">
                            <label for="merchantParntershipType" class="form-label" id="input-label">
                                Partnership Type<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="input-field" class="form-select" name="merchantParntershipType[]" required>
                                <option value="" disabled selected>-- Select Partnership Type --</option>
                                <option value="Primary">Primary</option>
                                <option value="Secondary">Secondary</option>
                                <option value="">Unknown Partnership Type</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="legal_entity_name" class="form-label" id="input-label">Legal Entity Name</label>
                            <input id="input-field" type="text" class="form-control" name="legal_entity_name[]" placeholder="Enter legal entity name" maxlength="255">
                        </div>
                        <div class="mb-3">
                            <label for="business_address" class="form-label" id="input-label">Business Address</label>
                            <input id="input-field" type="text" class="form-control" name="business_address[]" placeholder="Enter business address">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="email_address" class="form-label" id="input-label">Email Address</label>
                            <textarea id="input-field" class="form-control pb-3 pt-3" rows="5" name="email_address[]" placeholder="Enter email address"></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="sales" class="form-label" id="input-label">
                                Sales<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="input-field" class="form-select" name="sales[]" required>
                                <option value="" disabled selected>-- Select Sales --</option>
                                <?php fetchSales(); ?>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="account_manager" class="form-label" id="input-label">
                                Account Manager<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="input-field" class="form-select" name="account_manager[]" required>
                                <option value="" disabled selected>-- Select Account Manager --</option>
                                <?php fetchAccountManager(); ?>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3 mt-3" style="text-align:right;">
                        <button type="button" class="btn btn-danger remove-field" id="remove-field"><i class="fa-solid fa-trash"></i> Remove</button>
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

    document.getElementById('uploadForm').addEventListener('submit', function(event) {
        event.preventDefault(); // Prevent default form submission

        // Check if file name is 'Merchant Listing.csv'
        var fileInput = document.getElementById('fileToUpload');
        var fileName = fileInput.value.split('\\').pop(); // Get the file name without path

        if (fileName === '') {
            document.querySelector('.alert-custom').style.display = 'block'; // Show empty file alert
            setTimeout(function() {
                document.querySelector('.alert-custom').style.display = 'none'; // Hide after 3 seconds
            }, 3000);
            return; // Prevent form submission
        }

        if (fileName !== 'Merchant Listing.csv') {
            document.querySelector('.alert-custom-filename').style.display = 'block'; // Show filename alert
            setTimeout(function() {
                document.querySelector('.alert-custom-filename').style.display = 'none'; // Hide after 3 seconds
            }, 3000);
            return; // Prevent form submission
        }

        // Check file type
        if (!fileName.endsWith('.csv')) {
            document.querySelector('.alert-custom-filetype').style.display = 'block'; // Show file type alert
            setTimeout(function() {
                document.querySelector('.alert-custom-filetype').style.display = 'none'; // Hide after 3 seconds
            }, 3000);
            return; // Prevent form submission
        }

        // Get the file size in bytes
        var fileSize = fileInput.files[0].size; 

        // Update the submit button text with file size and show loading spinner
        var submitButton = document.getElementById('submitButton');
        var fileSizeKB = (fileSize / 1024).toFixed(2); 
        submitButton.innerHTML = `<div class="spinner-border spinner-border-sm" role="status"></div><span> Uploading (${fileSizeKB} KB)...</span>`;

        // Directly submit the form after updating the submit button
        document.getElementById('uploadForm').submit();
    });


    </script>
    <script>
         document.getElementById('dynamic-form').addEventListener('submit', function(event) {
        const form = event.target;
        const requiredFields = form.querySelectorAll('[required]');
        let isValid = true;

        requiredFields.forEach(field => {
            if (field.type === 'select-one' && !field.value) {
                isValid = false;
            } else if (field.type !== 'select-one' && !field.value.trim()) {
                isValid = false;
            }
        });

        if (!isValid) {
            event.preventDefault();
            alert('Please fill out all required fields.');
        }
    });
</script>
    <script src="../js/file_upload.js"></script>
</body>
</html>
