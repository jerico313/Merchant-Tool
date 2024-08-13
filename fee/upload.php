<?php 
include ("../header.php"); 

function fetchMerchants()
{
    include ("../inc/config.php");

    $merchantSql = "SELECT m.merchant_id, m.merchant_name 
                    FROM merchant m
                    LEFT JOIN fee f ON m.merchant_id = f.merchant_id
                    WHERE f.merchant_id IS NULL
                    ORDER BY m.merchant_name ASC";
    $merchantResult = $conn->query($merchantSql);

    if ($merchantResult->num_rows > 0) {
        while ($merchantRow = $merchantResult->fetch_assoc()) {
            echo "<option value='" . htmlspecialchars($merchantRow['merchant_id'], ENT_QUOTES, 'UTF-8') . "'>" . htmlspecialchars($merchantRow['merchant_name'], ENT_QUOTES, 'UTF-8') . "</option>";
        }
    } else {
        echo "<option value=''>No merchants found</option>";
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Merchants</title>
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
    </style>
</head>

<body>
    <div class="cont">
        <div class="custom-box pt-4">
            <a href="javascript:history.back()">
                <span class="back">
                    <i class="fa-regular fa-circle-left fa-lg"></i>
                    <span class="back-text"> Back to Fees</span>
                </span>
            </a>
            <div class="upload pt-4" style="text-align:left;">
                <form id="uploadForm" action="upload_process.php" method="post" enctype="multipart/form-data">
                    <div class="add-btns">
                        <p class="title">Upload Fees</p>
                        <button type="button" class="btn btn-primary check-report" id="addMerchantBtn">
                            <i class="fa-solid fa-plus"></i> Add New Fee
                        </button>
                    </div>

                    <div class="content">
                        <div class="file" style="padding:10px 10px 10px 0;font-size:15px;">
                            <p style="font-weight:bold;">Selected File: <span class="filename"
                                    style="color:#E96529"></span></p>
                        </div>
                        <label for="fileToUpload" style="background-color:#fff;font-size:20px;" class="upload-btn"
                            id="uploadBtn">
                            <i class="fa-solid fa-cloud-arrow-up fa-2xl"
                                style="font-size:40px;padding-bottom:30px;"></i>
                            <br>Choose a File
                        </label>
                        <input type="file" name="fileToUpload" id="fileToUpload" accept=".csv" style="display:none;">
                        <div class="uploadfile" style="text-align:right;">
                            <button type="button" class="btn btn-danger clear" id="clearButton">Clear</button>
                            <button type="submit" style="width: 190px;" class="btn btn-primary upload_file" id="submitButton">
                                <span>Submit</span>
                            </button>
                        </div>
                        <div class="file-preview" style="margin-top:20px;">
                            <div class="table-container">

                            </div>
                        </div>
                    </div>
                </form>
            </div>

            <div class="form" style="text-align:left;display:none;">
                <div class="add-btns pt-4">
                    <p class="title">Fee Details</p>
                    <button type="button" class="btn btn-primary check-report" id="uploadMerchantBtn">
                        <i class="fa-solid fa-upload"></i> Upload Fees
                    </button>
                    <button type="button" class="btn btn-primary check-report" id="add-field">
                        <i class="fa-solid fa-plus"></i> Add More 
                    </button>
                </div>

                <div class="content">
                    <form id="dynamic-form" action="add.php" method="POST">
                        <div id="form-fields">
                            <div class="form-group">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="merchant_id" class="form-label" id="form-input-label">
                                                Merchant Name<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <select id="form-input-field" class="form-select" name="merchant_id[]" required>
                                                <option value="" disabled selected>-- Select Merchant --</option>
                                                <?php fetchMerchants(); ?>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="paymaya_creditcard" class="form-label" id="form-input-label">
                                                Paymaya Credit Card, Maya Checkout, & Maya<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="paymaya_creditcard[]" step="0.01" id="paymaya_creditcard"placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="gcash" class="form-label"
                                                id="form-input-label">
                                                Gcash<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="gcash[]" id="gcash_miniapp" placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="gcash_miniapp" class="form-label"
                                                id="form-input-label">
                                                Gcash Miniapp<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="gcash_miniapp[]" id="gcash" placeholder="0.00" required>
                                        </div>
                                        
                                    </div>
                                    <div class="col-md-6">
                                    <div class="mb-3">
                                            <label for="Paymaya" class="form-label"
                                                id="form-input-label">Paymaya<span class="text-danger" style="padding:2px">*</span></label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="paymaya[]" id="paymaya" placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="leadgen_commission" class="form-label"
                                                id="form-input-label">Leadgen Commission<span class="text-danger" style="padding:2px">*</span></label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="leadgen_commission[]" id="leadgen_commission" placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="commission_type" class="form-label" id="form-input-label">Commission Type<span class="text-danger" style="padding:2px">*</span></label>
                                            <select id="form-input-field" class="form-select"
                                                name="commission_type[]" required>
                                                <option value="" disabled selected>-- Select Commission Type --</option>
                                                <option value="Vat Inc">Vat Inc</option>
                                                <option value="Vat Exc">Vat Exc</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="cwt_rate" class="form-label" id="form-input-label">
                                                CWT Rate<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="cwt_rate[]" placeholder="0.00" id="cwt_rate" required>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="submitButtonDiv">
                            <button type="submit" id="submitButton">Submit</button>
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
        <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Please upload the correct file named
        "Fee Listing.csv" !
    </div>

    <div class="alert-custom-filetype alert alert-danger" role="alert">
        <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> Please upload a file with .csv
        extension only!
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

        document.addEventListener("DOMContentLoaded", function () {
            document.getElementById('MerchantNum').dispatchEvent(new Event('input'));
        });

        document.getElementById('add-field').addEventListener('click', function () {
            var formFields = document.getElementById('form-fields');
            var newField = document.createElement('div');
            newField.classList.add('form-group');
            newField.innerHTML = `
                <div class="row">
                <hr style="border: 1px solid #3b3b3b;">
                 <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="merchant_id" class="form-label" id="form-input-label">
                                                Merchant Name<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <select id="form-input-field" class="form-select" name="merchant_id[]" required>
                                                <option value="" disabled selected>-- Select Merchant --</option>
                                                <?php fetchMerchants(); ?>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="paymaya_creditcard" class="form-label" id="form-input-label">
                                                Paymaya Credit Card, Maya Checkout, & Maya<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="paymaya_creditcard[]" step="0.01" id="paymaya_creditcard"placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="gcash" class="form-label"
                                                id="form-input-label">
                                                Gcash<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="gcash[]" id="gcash" placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="gcash_miniapp" class="form-label"
                                                id="form-input-label">
                                                Gcash Miniapp<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="gcash_miniapp[]" id="gcash_miniapp" placeholder="0.00" required>
                                        </div>
                                        
                                    </div>
                                    <div class="col-md-6">
                                    <div class="mb-3">
                                            <label for="Paymaya" class="form-label"
                                                id="form-input-label">Paymaya<span class="text-danger" style="padding:2px">*</span></label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="paymaya[]" id="paymaya" placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="leadgen_commission" class="form-label"
                                                id="form-input-label">Leadgen Commission<span class="text-danger" style="padding:2px">*</span></label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="leadgen_commission[]" id="leadgen_commission" placeholder="0.00" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="commission_type" class="form-label" id="form-input-label">Commission Type<span class="text-danger" style="padding:2px">*</span></label>
                                            <select id="form-input-field" class="form-select"
                                                name="commission_type[]" required>
                                                <option value="" disabled selected>-- Select Commission Type --</option>
                                                <option value="Vat Inc">Vat Inc</option>
                                                <option value="Vat Exc">Vat Exc</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="cwt_rate" class="form-label" id="form-input-label">
                                                CWT Rate<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="cwt_rate[]" placeholder="0.00" id="cwt_rate" required>
                                        </div>
                                    </div>
                    <div class="mb-3 mt-3" style="text-align:right;">
                        <button type="button" class="btn btn-danger remove-field" id="remove-field"><i class="fa-solid fa-trash"></i> Remove</button>
                    </div>
                </div>
            `;
            formFields.appendChild(newField);
            
            var newInputs = newField.querySelectorAll('input[type="number"]');
        newInputs.forEach(function(input) {
            input.addEventListener('blur', function() {
                var value = parseFloat(input.value).toFixed(2);
                input.value = isNaN(value) ? '' : value;
            });
        });
        });

        document.addEventListener('click', function (e) {
            if (e.target && e.target.classList.contains('remove-field')) {
                e.target.closest('.form-group').remove();
            }
        });

        document.getElementById('uploadForm').addEventListener('submit', function (event) {
            event.preventDefault(); 

            
            var fileInput = document.getElementById('fileToUpload');
            var fileName = fileInput.value.split('\\').pop(); 

            if (fileName === '') {
                document.querySelector('.alert-custom').style.display = 'block'; 
                setTimeout(function () {
                    document.querySelector('.alert-custom').style.display = 'none'; 
                }, 3000);
                return; 
            }

            if (fileName !== 'Fee Listing.csv') {
                document.querySelector('.alert-custom-filename').style.display = 'block'; 
                setTimeout(function () {
                    document.querySelector('.alert-custom-filename').style.display = 'none'; 
                }, 3000);
                return; 
            }

            if (!fileName.endsWith('.csv')) {
                document.querySelector('.alert-custom-filetype').style.display = 'block'; 
                setTimeout(function () {
                    document.querySelector('.alert-custom-filetype').style.display = 'none'; 
                }, 3000);
                return; 
            }

            var fileSize = fileInput.files[0].size;

            var submitButton = document.getElementById('submitButton');
            var fileSizeKB = (fileSize / 1024).toFixed(2);
            submitButton.innerHTML = `<div class="spinner-border spinner-border-sm" role="status"></div><span> Uploading (${fileSizeKB} KB)...</span>`;
            submitButton.disabled = true;
            
            document.getElementById('uploadForm').submit();
        });


    </script>
    <script>
        document.getElementById('dynamic-form').addEventListener('submit', function (event) {
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
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var inputs = document.querySelectorAll('input[type="number"]');

        inputs.forEach(function(input) {
            input.addEventListener('blur', function() {
                var value = parseFloat(input.value).toFixed(2);
                input.value = isNaN(value) ? '' : value;
            });
        });
    });
</script>
    <script src="../js/file_upload.js"></script>
</body>

</html>