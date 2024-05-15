<?php include_once("header.php")?>
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
<link rel="stylesheet" href="style.css">
<style>
    body {
      background-image: url("images/bg_booky.png");
      background-position: center;
      background-repeat: no-repeat;
      background-size: cover;
      background-attachment: fixed;
    }

    .title{
      font-size: 30px; 
      font-weight: bold; 
      margin-right: auto; 
      padding-left: 5vh;
      color: #E96529;"
    }

    .back{
      font-size: 20px; 
      font-weight: bold; 
      margin-right: auto; 
      padding-left: 5vh;
      color: #E96529;"
    }

    .add-btns{
      padding-bottom: 0px; 
      padding-right: 5vh; 
      display: flex; 
      align-items: center;
    }

    .table-transparent {
    border:solid 1px lightgrey;
    radius:10px;
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
  margin-top:70px;
  width: 99%;
  padding:20px;
  font-size:13px;
}

    </style>
</head>
<body>
<div class="cont-box">
  <div class="custom-box pt-5">
    <a href="transaction.php"><p class="back"><i class="fa-regular fa-circle-left fa-lg"></i></p></a>
    <div class="sub" style="text-align:left;">
      <div class="add-btns">
        <p class="title">Upload Orders</p>
        <form id="uploadForm" action="upload_transaction_process.php" method="post" enctype="multipart/form-data">
      </div>

      <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
        <div class="file" style="padding:10px 10px 10px 0;font-size:15px;"><p style="font-weight:bold;">Selected File: <span class="filename" style="color:#E96529"></span></p></div>
        <label for="fileToUpload" style="background-color:#fff;font-size:20px;" class="upload-btn" id="uploadBtn"><i class="fa-solid fa-cloud-arrow-up fa-2xl" style="font-size:40px;padding-bottom:30px;"></i><br>Choose a File or Drag it here </label>
        <input type="file" name="fileToUpload" id="fileToUpload" accept=".csv" style="display:none;">
        <div class="uploadfile" style="text-align:right;">
        <button type="submit" class="btn btn-secondary upload_file" id="submitButton">Submit</button>
        <div class="loading" id="loadingIndicator"><i class="fas fa-spinner fa-spin"></i> Loading...</div>
        </div>
        <div class="file-preview" style="margin-top:20px;background-color:#fff;"></div>
  </form>
      </div>
    </div>
  </div>
</div>

<!-- Custom Alert Box -->
<div class="alert-custom alert alert-danger" role="alert" style="border-left:solid 3px #f01e2c;">
<i class="fa-solid fa-circle-exclamation"></i> Please choose a file to upload!
</div>
<!-- End Custom Alert Box -->

<script>
  // JavaScript to display filename and preview
  document.getElementById('fileToUpload').addEventListener('change', function() {
    const filenameElement = document.querySelector('.filename');
    const filename = this.files[0].name;
    filenameElement.textContent = `Selected file: ${filename}`;

    // Preview the file content
    const previewArea = document.querySelector('.file-preview');
    previewArea.innerHTML = ''; // Clear previous preview
    const file = this.files[0];
    if (file.type === 'application/vnd.ms-excel' || file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || file.name.endsWith('.csv')) {
      const reader = new FileReader();
      reader.onload = function(event) {
        const contents = event.target.result;
        const lines = contents.split('\n');
        const table = document.createElement('table');
        table.classList.add('table', 'table-bordered', 'table-striped', 'mt-3', 'mb-5', 'table-transparent');
        const tbody = document.createElement('tbody');
        for (let i = 0; i < Math.min(5, lines.length); i++) {
          const cells = splitCSVLine(lines[i]); // Use custom function to handle CSV parsing
          const row = document.createElement('tr');
          for (let j = 0; j < cells.length; j++) {
            const cell = document.createElement('td');
            cell.textContent = cells[j];
            row.appendChild(cell);
          }
          tbody.appendChild(row);
        }
        table.appendChild(tbody);
        previewArea.appendChild(table);
      }
      reader.readAsText(file);
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

  document.getElementById('uploadForm').addEventListener('submit', function(event) {
    // Prevent default form submission
    event.preventDefault();
    
    // Check if a file has been selected
    const fileInput = document.getElementById('fileToUpload');
    if (fileInput.files.length === 0) {
      $('.alert-custom').fadeIn();
      setTimeout(function(){
        $('.alert-custom').fadeOut();
      }, 3000); // Hide the alert after 3 seconds
      return;
    }

    // Show loading indicator inside the submit button
    const submitButton = document.getElementById('submitButton');
    submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Uploading...';
    submitButton.disabled = true;

    // Delay form submission for one minute
    setTimeout(function() {
      // Restore submit button state
      submitButton.innerHTML = 'Submit';
      submitButton.disabled = false;

      // Submit the form
      document.getElementById('uploadForm').submit();
    }, 8000); // 60000 milliseconds = 1 minute
  });

    // JavaScript for drag and drop functionality
    const uploadBtn = document.getElementById('uploadBtn');

uploadBtn.addEventListener('dragenter', function(e) {
  e.preventDefault();
  e.stopPropagation();
  uploadBtn.classList.add('dragover');
});

uploadBtn.addEventListener('dragover', function(e) {
  e.preventDefault();
  e.stopPropagation();
  uploadBtn.classList.add('dragover');
});

uploadBtn.addEventListener('dragleave', function(e) {
  e.preventDefault();
  e.stopPropagation();
  uploadBtn.classList.remove('dragover');
});

uploadBtn.addEventListener('drop', function(e) {
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
