<?php include ("../../header.php") ?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
?>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Store</title>
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
            font-weight: 1000;
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
                            style="font-size:17px;color:grey;cursor:pointer;"> Back to Stores</span></span></a>
                <div class="upload pt-4" style="text-align:left;">
                    <div class="add-btns">
                        <p class="title">Store Details</p>
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
                                                <label for="store_id" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Store ID</label>
                                                <input type="text" class="form-control" name="store_id[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;"
                                                    required>
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
                                                <label for="store_name" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Store Name</label>
                                                <input type="text" class="form-control" name="store_name[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                            </div>

                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="legal_entity_name" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Legal Entity Name</label>
                                                <input type="text" class="form-control" name="legal_entity_name[]"
                                                    style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                            </div>
                                            <div class="mb-3">
                                                <label for="store_address" class="form-label"
                                                    style="font-size:15px;font-weight:bold;">Store Address</label>
                                                <input type="text" class="form-control" name="store_address[]"
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

    <div class="alert-custom alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
        <i class="fa-solid fa-circle-exclamation"></i> Please choose a file to upload!
    </div>

    <div class="alert-custom-filename alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
        <i class="fa-solid fa-circle-exclamation"></i> Please upload the correct file named "Store Listing.csv" !
    </div>

    <div class="alert-custom-filetype alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
        <i class="fa-solid fa-circle-exclamation"></i> Please upload a file with .csv extension only!
    </div>
    <script src="../../js/file_upload.js"></script>
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
                                    <label for="store_id" class="form-label" style="font-size:15px;font-weight:bold;">Store ID</label>
                                    <input type="text" class="form-control" name="store_id[]" style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_name" class="form-label" style="font-size:15px;font-weight:bold;">Merchant Name</label>
                                    <input type="text" class="form-control" value="<?php echo htmlspecialchars($merchant_name); ?>" name="merchant_name[]" style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;background-color:#d3d3d3;" readonly required>
                                    <input type="hidden" class="form-control" value="<?php echo htmlspecialchars($merchant_id); ?>" name="merchant_id[]" style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;background-color:#d3d3d3;" readonly required>
                                </div>
                                <div class="mb-3">
                                    <label for="store_name" class="form-label" style="font-size:15px;font-weight:bold;">Store Name</label>
                                    <input type="text" class="form-control" name="store_name[]" style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                </div>
                                
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="legal_entity_name" class="form-label" style="font-size:15px;font-weight:bold;">Legal Entity Name</label>
                                    <input type="text" class="form-control" name="legal_entity_name[]" style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="store_address" class="form-label" style="font-size:15px;font-weight:bold;">Store Address</label>
                                    <input type="text" class="form-control" name="store_address[]" style="border-radius:20px;padding:10px 20px;border: 2px dashed #928a89;" required>
                                </div>
                            </div>
                            <div class="mb-3 mt-3" style="text-align:right;">
                                <button type="button" class="btn btn-danger remove-field" id="remove-field"><i class="fa-solid fa-trash"></i> Remove</button>
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

            if (fileName !== 'Store Listing.csv') {
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
   
</body>

</html>