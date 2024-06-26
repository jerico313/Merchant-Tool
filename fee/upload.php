<?php include ("../header.php") ?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
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
                            style="font-size:17px;color:grey;cursor:pointer;"> Back to Fees</span></span></a>
                <div class="upload pt-3" style="text-align:left;">
                    <div class="add-btns">
                        <p class="title">Upload Fees</p>
                        <form id="uploadForm" action="upload_process.php" method="post" enctype="multipart/form-data">
                    </div>

                    <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                        <div class="file" style="padding:10px 10px 10px 0;font-size:15px;">
                            <p style="font-weight:bold;">Selected File: <span class="filename"
                                    style="color:#E96529"></span></p>
                        </div>
                        <label for="fileToUpload" style="background-color:#fff;font-size:20px;" class="upload-btn"
                            id="uploadBtn"><i class="fa-solid fa-cloud-arrow-up fa-2xl"
                                style="font-size:40px;padding-bottom:30px;"></i><br>Choose a File</label>
                        <input type="file" name="fileToUpload" id="fileToUpload" accept=".csv" style="display:none;">
                        <div class="uploadfile" style="text-align:right;">
                            <button type="button" class="btn btn-danger clear" id="clearButton">Clear</button>
                            <button type="submit" class="btn btn-secondary upload_file"
                                id="submitButton"><span>Submit</span></button>
                        </div>
                        <div class="file-preview" style="margin-top:20px;">
                            <div class="table-container">
                                <!-- Table will be appended here -->
                            </div>
                        </div>
                        </form>
                    </div>
                </div>

                <div class="alert-custom alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
                    <i class="fa-solid fa-circle-exclamation"></i> Please choose a file to upload!
                </div>

                <div class="alert-custom-filename alert alert-danger" role="alert"
                    style="border-left:solid 3px #f01e2c;">
                    <i class="fa-solid fa-circle-exclamation"></i> Please upload the correct file named "Fee
                    Listing.csv" !
                </div>

                <div class="alert-custom-filetype alert alert-danger" role="alert"
                    style="border-left:solid 3px #f01e2c;">
                    <i class="fa-solid fa-circle-exclamation"></i> Please upload a file with .csv extension only!
                </div>

                <script>
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

                        if (fileName !== 'Fee Listing.csv') {
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
                <script src="../js/file_upload.js"></script>
</body>

</html>