<?php include ("../../header.php") ?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
?>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Homepage</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/papaparse@5.3.0/papaparse.min.js"></script>
    <link rel="stylesheet" href="../../style.css">
    <style>
        body {
            background-image: url("../../images/bg_booky.png");
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

        .alert-custom,
        .alert-custom-filename,
        .alert-custom-filetype {
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
            <span><a href="javascript:history.back()"><span class="back"><i
                            class="fa-regular fa-circle-left fa-lg"></i><span
                            style="font-size:17px;color:grey;cursor:pointer;"> Back to Promos</span></span></a>
                

                <div class="form pt-4" style="text-align:left;">
                    <div class="add-btns">
                        <p class="title">Promo Details</p>
                        <button type="button" class="btn btn-success" id="add-field"><i class="fa-solid fa-plus"></i>
                            Add More </button>
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
                                                <label for="promo_id" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Promo Code</label>
                                                <input type="text" class="form-control" name="promo_code[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                            </div>
                                            <div class="mb-3">
                                                <label for="merchant_name" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Merchant Name</label>
                                                <input type="text" class="form-control"
                                                    value="<?php echo htmlspecialchars($merchant_name); ?>"
                                                    name="merchant_name[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;background-color:#d3d3d3;"
                                                    readonly required>
                                                <input type="hidden" class="form-control"
                                                    value="<?php echo htmlspecialchars($merchant_id); ?>"
                                                    name="merchant_id[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;background-color:#d3d3d3;"
                                                    readonly required>

                                            </div>
                                            <div class="mb-3">
                                                <label for="promo_amount" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Promo Amount</label>
                                                <input type="text" class="form-control" name="promo_amount[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                            </div>
                                            <div class="mb-3">
                                                <label for="voucher_type" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Voucher Type</label>
                                                <select class="form-select" id="voucher_type" name="voucher_type[]"
                                                    style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                                    <option value="">-- Select Voucher Type --</option>
                                                    <option value="Coupled">Coupled</option>
                                                    <option value="Decoupled">Decoupled</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label for="promo_category" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Promo Category</label>
                                                <select class="form-select" id="promo_category" name="promo_category[]"
                                                    style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                                    <option value="">-- Select Promo Category --</option>
                                                    <option value="Grab & Go">Grab & Go</option>
                                                    <option value="Casual Dining">Casual Dining</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label for="promo_group" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Promo Group</label>
                                                <select class="form-select" id="promo_group" name="promo_group[]"
                                                    style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                                    <option value="">-- Select Promo Group --</option>
                                                    <option value="Grab & Go">Booky</option>
                                                    <option value="Gcash">Gcash</option>
                                                    <option value="Unionbank">Unionbank</option>
                                                    <option value="Gcash/Booky">Gcash/Booky</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label for="promo_type" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Promo Type</label>
                                                <select class="form-select" id="promo_type" name="promo_type[]"
                                                    style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                                    <option value="">-- Select Promo Group --</option>
                                                    <option value="BOGO">BOGO</option>
                                                    <option value="Bundle">Bundle</option>
                                                    <option value="Fixed discount">Fixed discount</option>
                                                    <option value="Free item">Free item</option>
                                                    <option value="Free discount, Free item">Free discount, Free item</option>
                                                    <option value="Percent discount">Percent discount</option>
                                                    <option value="X for Y">X for Y</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="promo_details" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Promo Details</label>
                                                <textarea class="form-control" rows="5" name="promo_details[]"
                                                    style="border-radius:20px;padding:15px 15px;border: 2px dashed #928a89;"
                                                    required></textarea>
                                            </div>
                                            <div class="mb-3">
                                                <label for="remarks" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Remarks</label>
                                                <input type="text" class="form-control" name="remarks[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;">
                                            </div>
                                            <div class="mb-3">
                                                <label for="bill_status" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Bill Status</label>
                                                <select class="form-select" id="bill_status" name="bill_status[]"
                                                    style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                                    <option value="">-- Select Bill Status --</option>
                                                    <option value="PRE-TRIAL">PRE-TRIAL</option>
                                                    <option value="BILLABLE">BILLABLE</option>
                                                    <option value="NOT BILLABLE">NOT BILLABLE</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label for="start_date" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Start Date</label>
                                                <input type="date" class="form-control" id="start_date"
                                                    name="start_date[]"
                                                    style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;">
                                            </div>
                                            <div class="mb-3">
                                                <label for="end_date" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">End Date</label>
                                                <input type="date" class="form-control" id="end_date" name="end_date[]"
                                                    style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;">
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

    <div class="alert-custom alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
        <i class="fa-solid fa-circle-exclamation"></i> Please choose a file to upload!
    </div>

    <div class="alert-custom-filename alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
        <i class="fa-solid fa-circle-exclamation"></i> Please upload the correct file named "Promo Listing.csv" !
    </div>

    <div class="alert-custom-filetype alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
        <i class="fa-solid fa-circle-exclamation"></i> Please upload a file with .csv extension only!
    </div>

    <script>
        document.getElementById('add-field').addEventListener('click', function () {
            var formFields = document.getElementById('form-fields');
            var newField = document.createElement('div');
            newField.classList.add('form-group');
            newField.innerHTML = `
            <div class="row">
        <hr style="border: 1px solid #3b3b3b;">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="promo_id" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Promo Code</label>
                                    <input type="text" class="form-control" name="promo_code[]"
                                        style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_name" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Merchant Name</label>
                                    <input type="text" class="form-control"
                                        value="<?php echo htmlspecialchars($merchant_name); ?>" name="merchant_name[]"
                                        style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;background-color:#d3d3d3;"
                                        readonly required>
                                    <input type="hidden" class="form-control"
                                        value="<?php echo htmlspecialchars($merchant_id); ?>" name="merchant_id[]"
                                        style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;background-color:#d3d3d3;"
                                        readonly required>

                                </div>
                                <div class="mb-3">
                                    <label for="promo_amount" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Promo Amount</label>
                                    <input type="text" class="form-control" name="promo_amount[]"
                                        style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="voucher_type" class="form-label" style="font-size:15px;font-weight:bold;">Voucher Type</label>
                                    <select class="form-select" id="voucher_type" name="voucher_type[]" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                        <option value="">-- Select Voucher Type --</option>
                                        <option value="Coupled">Coupled</option>
                                        <option value="Decoupled">Decoupled</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_category" class="form-label" style="font-size:15px;font-weight:bold;">Promo Category</label>
                                    <select class="form-select" id="promo_category" name="promo_category[]" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                        <option value="">-- Select Promo Category --</option>
                                        <option value="Grab & Go">Grab & Go</option>
                                        <option value="Casual Dining">Casual Dining</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_group" class="form-label" style="font-size:15px;font-weight:bold;">Promo Group</label>
                                    <select class="form-select" id="promo_group" name="promo_group[]" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                        <option value="">-- Select Promo Group --</option>
                                        <option value="Grab & Go">Booky</option>
                                        <option value="Gcash">Gcash</option>
                                        <option value="Unionbank">Unionbank</option>
                                        <option value="Gcash/Booky">Gcash/Booky</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_type" class="form-label" style="font-size:15px;font-weight:bold;">Promo Type</label>
                                    <select class="form-select" id="promo_type" name="promo_type[]" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                        <option value="">-- Select Promo Group --</option>
                                        <option value="BOGO">BOGO</option>
                                        <option value="Bundle">Bundle</option>
                                        <option value="Fixed discount">Fixed discount</option>
                                        <option value="Free item">Free item</option>
                                        <option value="Free discount, Free item">Free discount, Free item</option>
                                        <option value="Percent discount">Percent discount</option>
                                        <option value="X for Y">X for Y</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="promo_details" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Promo Details</label>
                                        <textarea class="form-control" rows="5" name="promo_details[]" style="border-radius:20px;padding:15px 15px;border: 2px dashed #928a89;" required></textarea>
                                </div>
                                <div class="mb-3">
                                    <label for="remarks" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Remarks</label>
                                    <input type="text" class="form-control" name="remarks[]"
                                        style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;">
                                </div>
                            <div class="mb-3">
                                <label for="bill_status" class="form-label" style="font-size:15px;font-weight:bold;">Bill Status</label>
                                <select class="form-select" id="bill_status" name="bill_status[]" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;" required>
                                    <option value="">-- Select Bill Status --</option>
                                    <option value="PRE-TRIAL">PRE-TRIAL</option>
                                    <option value="BILLABLE">BILLABLE</option>
                                    <option value="NOT BILLABLE">NOT BILLABLE</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="start_date" class="form-label" style="font-size:15px;font-weight:bold;">Start Date</label>
                                <input type="date" class="form-control" id="start_date" name="start_date[]" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;">
                            </div>
                            <div class="mb-3">
                                <label for="end_date" class="form-label" style="font-size:15px;font-weight:bold;">End Date</label>
                                <input type="date" class="form-control" id="end_date" name="end_date[]" style="border-radius:20px;padding:11px 20px;border: 2px dashed #928a89;">
                            </div>
                            </div>
                            <div class="mb-3 mt-3" style="text-align:right;">
                                <button type="button" class="btn btn-danger remove-field"><i class="fa-solid fa-trash"></i> Remove</button>
                            </div>
                        </div>
        `;
            formFields.appendChild(newField);
        });

        document.addEventListener('click', function (e) {
            if (e.target && e.target.classList.contains('remove-field')) {
                e.target.closest('.form-group').remove();
            }
        });

        document.getElementById('uploadForm').addEventListener('submit', function (event) {
            event.preventDefault(); // Prevent default form submission

            // Check if file name is 'Merchant Listing.csv'
            var fileInput = document.getElementById('fileToUpload');
            var fileName = fileInput.value.split('\\').pop(); // Get the file name without path

            if (fileName === '') {
                document.querySelector('.alert-custom').style.display = 'block'; // Show empty file alert
                setTimeout(function () {
                    document.querySelector('.alert-custom').style.display = 'none'; // Hide after 3 seconds
                }, 3000);
                return; // Prevent form submission
            }

            if (fileName !== 'Promo Listing.csv') {
                document.querySelector('.alert-custom-filename').style.display = 'block'; // Show filename alert
                setTimeout(function () {
                    document.querySelector('.alert-custom-filename').style.display = 'none'; // Hide after 3 seconds
                }, 3000);
                return; // Prevent form submission
            }

            // Check file type
            if (!fileName.endsWith('.csv')) {
                document.querySelector('.alert-custom-filetype').style.display = 'block'; // Show file type alert
                setTimeout(function () {
                    document.querySelector('.alert-custom-filetype').style.display = 'none'; // Hide after 3 seconds
                }, 3000);
                return; // Prevent form submission
            }

            // Get the file size in bytes
            var fileSize = fileInput.files[0].size;

            // Update the submit button text with file size and show loading spinner
            var submitButton = document.getElementById('submitButton');
            var fileSizeKB = (fileSize / 1024).toFixed(2); // Convert bytes to KB
            submitButton.innerHTML = `<div class="spinner-border spinner-border-sm" role="status"></div><span> Uploading (${fileSizeKB} KB)...</span>`;

            // If valid, simulate loading time based on file size and submit the form
            var loadingTime = fileSize / 1024; // Simulate loading time in seconds based on file size
            setTimeout(function () {
                document.getElementById('uploadForm').submit();
            }, loadingTime * 1000);
        });

    </script>
    <script src="../../js/file_upload.js"></script>
</body>

</html>