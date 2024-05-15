<?php include_once("header.php") ?>
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
            padding: 20px;
            font-size: 13px;
        }

        .or {
            width: 100%;
            text-align: center;
            border-bottom: 1px solid #000;
            line-height: 0.1em;
            margin: 10px 0 20px;
        }

        .or span {
            background: #F1F1F1;
            padding: 0 10px;
            font-size: 15px;
        }

        .table-container {
            overflow-x: auto;
            margin-left: auto;
            margin-right: auto;
        }
    </style>
</head>
<body>

<div class="cont-box">
    <div class="custom-box pt-5">
        <a href="merchant.php">
            <p class="back"><i class="fa-regular fa-circle-left fa-lg"></i></p>
        </a>
        <div class="sub" style="text-align:left;">
            <div class="add-btns">
                <p class="title">Upload Merchants</p>
                <form id="uploadForm" action="upload_merchant_process.php" method="post" enctype="multipart/form-data">
            </div>

            <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                <div class="file" style="padding:10px 10px 10px 0;font-size:15px;">
                    <p style="font-weight:bold;">Selected File: <span class="filename"
                                                                      style="color:#E96529"></span></p>
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
                <div class="file-preview" style="margin-top:20px;background-color:#fff;">
                    <div class="table-container">
                        <!-- Table will be appended here -->
                    </div>
                </div>
                </form>
                <p class="or"><span>or</span></p>
            </div>
        </div>
    </div>
</div>

<div class="alert-custom alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
    <i class="fa-solid fa-circle-exclamation"></i> Please choose a file to upload!
</div>

<script>
    document.getElementById('fileToUpload').addEventListener('change', function () {
    const filenameElement = document.querySelector('.filename');
    const filename = this.files[0].name;
    filenameElement.textContent = `Selected file: ${filename}`;

    // Preview the file content
    const previewArea = document.querySelector('.file-preview .table-container');
    previewArea.innerHTML = ''; // Clear previous preview
    const file = this.files[0];

    if (file.type === 'application/vnd.ms-excel' || file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || file.name.endsWith('.csv')) {
        Papa.parse(file, {
            header: true,
            dynamicTyping: true,
            complete: function(results) {
                const data = results.data;
                const table = document.createElement('table');
                table.classList.add('table', 'table-bordered', 'table-striped', 'mt-3', 'mb-5', 'table-transparent', 'table-responsive');
                const thead = document.createElement('thead');
                const tbody = document.createElement('tbody');
                
                // Display header (first row)
                const headerRow = document.createElement('tr');
                for (let key in data[0]) {
                    const th = document.createElement('th');
                    th.textContent = key;
                    headerRow.appendChild(th);
                }
                thead.appendChild(headerRow);
                table.appendChild(thead);

                // Display data
                for (let i = 0; i < Math.min(10, data.length); i++) {
                    const row = document.createElement('tr');
                    for (let key in data[i]) {
                        const cell = document.createElement('td');
                        cell.textContent = data[i][key];
                        row.appendChild(cell);
                    }
                    tbody.appendChild(row);
                }
                table.appendChild(tbody);
                previewArea.appendChild(table);
            }
        });
    } else {
        const pElement = document.createElement('p');
        pElement.textContent = 'File preview not available';
        previewArea.appendChild(pElement);
    }
});

    // Custom function to handle CSV line parsing
    function splitCSVLine(line) {
        const values = [];
        let currentValue = '';
        let inQuotes = false;
        for (let i = 0; i < line.length; i++) {
            const char = line.charAt(i);
            if (char === '"') {
                inQuotes = !inQuotes;
            } else if (char === ',' && !inQuotes) {
                values.push(currentValue.trim());
                currentValue = '';
            } else {
                currentValue += char;
            }
        }
        values.push(currentValue.trim());
        return values;
    }

    document.getElementById('uploadForm').addEventListener('submit', function (event) {
        // Prevent default form submission
        event.preventDefault();

        // Check if a file has been selected
        const fileInput = document.getElementById('fileToUpload');
        if (fileInput.files.length === 0) {
            $('.alert-custom').fadeIn();
            setTimeout(function () {
                $('.alert-custom').fadeOut();
            }, 3000); // Hide the alert after 3 seconds
            return;
        }

        // Show loading indicator inside the submit button
        const submitButton = document.getElementById('submitButton');
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Uploading...';
        submitButton.disabled = true;

        // Delay form submission for one minute
        setTimeout(function () {
            // Restore submit button state
            submitButton.innerHTML = 'Submit';
            submitButton.disabled = false;

            // Submit the form
            document.getElementById('uploadForm').submit();
        }, 8000); // 60000 milliseconds = 1 minute
    });

    // JavaScript for drag and drop functionality
    const uploadBtn = document.getElementById('uploadBtn');

    uploadBtn.addEventListener('dragenter', function (e) {
        e.preventDefault();
        e.stopPropagation();
        uploadBtn.classList.add('dragover');
    });

    uploadBtn.addEventListener('dragover', function (e) {
        e.preventDefault();
        e.stopPropagation();
        uploadBtn.classList.add('dragover');
    });

    uploadBtn.addEventListener('dragleave', function (e) {
        e.preventDefault();
        e.stopPropagation();
        uploadBtn.classList.remove('dragover');
    });

    uploadBtn.addEventListener('drop', function (e) {
        e.preventDefault();
        e.stopPropagation();
        uploadBtn.classList.remove('dragover');

        const files = e.dataTransfer.files;
        document.getElementById('fileToUpload').files = files;
        // Trigger change event to handle the file
        const event = new Event('change');
        document.getElementById('fileToUpload').dispatchEvent(event);
    });
</script>
</body>
</html>
