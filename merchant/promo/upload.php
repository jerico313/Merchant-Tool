<?php include ("../../header.php") ?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
?>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Promo</title>
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
        }
    </style>
</head>

<body>
    <div class="cont">
        <div class="custom-box pt-4">
            <a href="javascript:history.back()">
                <span class="back">
                    <i class="fa-regular fa-circle-left fa-lg"></i>
                    <span class="back-text"> Back to Promos</span>
                </span>
            </a>

            <div class="upload pt-4" style="text-align:left;">
                <div class="add-btns">
                    <p class="title">Add New Promo</p>
                    <button type="button" class="btn btn-success" id="add-field"><i class="fa-solid fa-plus"></i>
                        Add More </button>
                </div>

                <div class="content">
                    <form id="dynamic-form"
                        action="add.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>"
                        method="POST">
                        <div id="form-fields">
                            <div class="form-group">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="promo_id" class="form-label" id="form-input-label">
                                                Promo Code<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="text" class="form-control"
                                                name="promo_code[]" placeholder="Enter promo code" required
                                                maxlength="100">
                                        </div>
                                        <div class="mb-3">
                                            <label for="merchant_name" class="form-label" id="form-input-label">
                                                Merchant Name<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="text" class="form-control"
                                                style="background-color: #d3d3d3; caret-color: transparent;"
                                                value="<?php echo htmlspecialchars($merchant_name); ?>"
                                                name="merchant_name[]" readonly required>
                                            <input id="form-input-field" type="hidden" class="form-control"
                                                value="<?php echo htmlspecialchars($merchant_id); ?>"
                                                name="merchant_id[]" readonly required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="promo_amount" class="form-label" id="form-input-label">
                                                Promo Amount<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="number" class="form-control"
                                                name="promo_amount[]" placeholder="0" min="0" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="voucher_type" class="form-label" id="form-input-label">
                                                Voucher Type<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <select id="form-input-field" class="form-select" name="voucher_type[]"
                                                required>
                                                <option disabled selected>-- Select Voucher Type --</option>
                                                <option value="Coupled">Coupled</option>
                                                <option value="Decoupled">Decoupled</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="promo_category" class="form-label" id="form-input-label">
                                                Promo Category<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <select id="form-input-field" class="form-select" name="promo_category[]"
                                                required>
                                                <option disabled selected>-- Select Promo Category --</option>
                                                <option value="Grab & Go">Grab & Go</option>
                                                <option value="Casual Dining">Casual Dining</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="promo_group" class="form-label" id="form-input-label">
                                                Promo Group<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <select id="form-input-field" class="form-select" name="promo_group[]"
                                                required>
                                                <option disabled selected>-- Select Promo Group --</option>
                                                <option value="Grab & Go">Booky</option>
                                                <option value="Gcash">Gcash</option>
                                                <option value="Unionbank">Unionbank</option>
                                                <option value="Gcash/Booky">Gcash/Booky</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="promo_type" class="form-label" id="form-input-label">
                                                Promo Type<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <select id="form-input-field" class="form-select" name="promo_type[]"
                                                required>
                                                <option disabled selected>-- Select Promo Type --</option>
                                                <option value="BOGO">BOGO</option>
                                                <option value="Bundle">Bundle</option>
                                                <option value="Fixed discount">Fixed discount</option>
                                                <option value="Free item">Free item</option>
                                                <option value="Fixed discount, Free item">Free discount, Free item
                                                </option>
                                                <option value="Percent discount">Percent discount</option>
                                                <option value="X for Y">X for Y</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="promo_details" class="form-label" id="form-input-label">
                                                Promo Details<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <textarea id="form-input-field" class="form-control" rows="3"
                                                name="promo_details[]" placeholder="Enter promo details"
                                                required></textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label for="remarks" class="form-label"
                                                id="form-input-label">Remarks</label>
                                            <textarea id="form-input-field" class="form-control" rows="2"
                                                name="remarks[]" placeholder="Enter remarks"></textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label for="bill_status" class="form-label" id="form-input-label">
                                                Bill Status<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <select id="form-input-field" class="form-select" name="bill_status[]"
                                                required>
                                                <option disabled selected>-- Select Bill Status --</option>
                                                <option value="PRE-TRIAL">PRE-TRIAL</option>
                                                <option value="BILLABLE">BILLABLE</option>
                                                <option value="NOT BILLABLE">NOT BILLABLE</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="start_date" class="form-label" id="form-input-label">
                                                Start Date<span class="text-danger" style="padding:2px">*</span>
                                                <input type="checkbox" class="form-check-input" id="NoStartDate"
                                                    name="NoStartDate" style="accent-color:#E96529;">
                                                <label class="form-check-label" for="NoStartDate">No Start Date</label>
                                            </label>
                                            <input type="date" class="form-control"
                                                name="start_date[]" id="start_date" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="end_date" class="form-label" id="form-input-label">
                                                End Date<span class="text-danger" style="padding:2px">*</span>
                                                <input type="checkbox" class="form-check-input" id="NoEndDate"
                                                    name="NoEndDate" style="accent-color:#E96529 !important;">
                                                <label class="form-check-label" for="NoEndDate">No End Date</label>
                                            </label>
                                            <input type="date" class="form-control"
                                                name="end_date[]" id="end_date" disrequired>
                                        </div>
                                        <div class="mb-3">
                                            <label for="remarks2" class="form-label" id="form-input-label">Remarks 2</label>
                                            <textarea id="form-input-field" class="form-control" rows="2"
                                                name="remarks2[]" placeholder="Enter additional remarks"></textarea>
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
                <hr style="border: 1px solid #3b3b3b;">
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="promo_id" class="form-label" id="form-input-label">
                                Promo Code<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="form-input-field" type="text" class="form-control" 
                                name="promo_code[]" placeholder="Enter promo code" 
                                required maxlength="100">
                        </div>
                        <div class="mb-3">
                            <label for="merchant_name" class="form-label" id="form-input-label">
                                Merchant Name<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="form-input-field" type="text" class="form-control"
                                style="background-color: #d3d3d3; caret-color: transparent;"
                                value="<?php echo htmlspecialchars($merchant_name); ?>"
                                name="merchant_name[]" readonly required>
                            <input id="form-input-field" type="hidden" class="form-control"
                                value="<?php echo htmlspecialchars($merchant_id); ?>"
                                name="merchant_id[]" readonly required>
                        </div>
                        <div class="mb-3">
                            <label for="promo_amount" class="form-label" id="form-input-label">
                                Promo Amount<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="form-input-field" type="number" class="form-control" 
                                name="promo_amount[]" placeholder="0"                                                
                                min="0" required>
                        </div>
                        <div class="mb-3">
                            <label for="voucher_type" class="form-label" id="form-input-label">
                                Voucher Type<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="form-input-field" class="form-select" name="voucher_type[]" required>
                                <option disabled selected>-- Select Voucher Type --</option>
                                <option value="Coupled">Coupled</option>
                                <option value="Decoupled">Decoupled</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="promo_category" class="form-label" id="form-input-label">
                                Promo Category<span class="text-danger" style="padding:2px">*</span>                                                
                            </label>
                            <select id="form-input-field" class="form-select" name="promo_category[]" required>
                                <option disabled selected>-- Select Promo Category --</option>
                                <option value="Grab & Go">Grab & Go</option>
                                <option value="Casual Dining">Casual Dining</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="promo_group" class="form-label" id="form-input-label">
                                Promo Group<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="form-input-field" class="form-select" name="promo_group[]" required>
                                <option disabled selected>-- Select Promo Group --</option>
                                <option value="Grab & Go">Booky</option>
                                <option value="Gcash">Gcash</option>
                                <option value="Unionbank">Unionbank</option>
                                <option value="Gcash/Booky">Gcash/Booky</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="promo_type" class="form-label" id="form-input-label">
                                Promo Type<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="form-input-field" class="form-select" name="promo_type[]" required>
                                <option disabled selected>-- Select Promo Type --</option>
                                <option value="BOGO">BOGO</option>
                                <option value="Bundle">Bundle</option>
                                <option value="Fixed discount">Fixed discount</option>
                                <option value="Free item">Free item</option>
                                <option value="Fixed discount, Free item">Free discount, Free item</option>
                                <option value="Percent discount">Percent discount</option>
                                <option value="X for Y">X for Y</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="promo_details" class="form-label" id="form-input-label">
                                Promo Details<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <textarea id="form-input-field" class="form-control" rows="3"
                                name="promo_details[]" placeholder="Enter promo details" required></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="remarks" class="form-label" id="form-input-label">Remarks</label>
                            <textarea id="form-input-field" class="form-control" rows="2"
                                name="remarks[]" placeholder="Enter remarks"></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="bill_status" class="form-label" id="form-input-label">
                                Bill Status<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <select id="form-input-field" class="form-select" name="bill_status[]" required>
                                <option disabled selected>-- Select Bill Status --</option>
                                <option value="PRE-TRIAL">PRE-TRIAL</option>
                                <option value="BILLABLE">BILLABLE</option>
                                <option value="NOT BILLABLE">NOT BILLABLE</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="start_date" class="form-label" id="form-input-label">
                                Start Date<span class="text-danger" style="padding:2px">*</span>
                                <input type="checkbox" class="form-check-input" id="NoStartDate"
                                    name="NoStartDate" style="accent-color:#E96529;">
                                <label class="form-check-label" for="NoStartDate">No Start Date</label>
                            </label>
                            <input id="start_date" type="date" class="form-control" name="start_date[]" required>
                        </div>
                        <div class="mb-3">
                            <label for="end_date" class="form-label" id="form-input-label">
                                End Date<span class="text-danger" style="padding:2px">*</span>
                                <input type="checkbox" class="form-check-input" id="NoEndDate"
                                    name="NoEndDate" style="accent-color:#E96529 !important;">
                                <label class="form-check-label" for="NoEndDate">No End Date</label>
                            </label>
                            <input id="end_date" type="date" class="form-control" name="end_date[]" required>
                        </div>
                        <div class="mb-3">
                            <label for="remarks2" class="form-label" id="form-input-label">Remarks 2</label>
                            <textarea id="form-input-field" class="form-control" rows="2"
                                name="remarks2[]" placeholder="Enter additional remarks"></textarea>
                        </div>
                    </div>
                    <div class="mb-3 mt-3" style="text-align:right;">
                        <button type="button" class="btn btn-danger remove-field" id="remove-field">
                            <i class="fa-solid fa-trash"></i> Remove
                        </button>
                    </div>
                </div>
        `;
            formFields.appendChild(newField);
            
        });

        document.getElementById('form-fields').addEventListener('change', function (e) {
        if (e.target && e.target.id === 'NoStartDate') {
            var startDateInput = e.target.closest('.row').querySelector('#start_date');
            if (e.target.checked) {
                startDateInput.value = ''; 
                startDateInput.disabled = true; 
            } else {
                startDateInput.disabled = false; 
            }
        }

        if (e.target && e.target.id === 'NoEndDate') {
            var endDateInput = e.target.closest('.row').querySelector('#end_date');
            if (e.target.checked) {
                endDateInput.value = ''; 
                endDateInput.disabled = true; 
            } else {
                endDateInput.disabled = false; 
            }
        }
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

            if (fileName !== 'Promo Listing.csv') {
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

            var loadingTime = fileSize / 1024; 
            setTimeout(function () {
                document.getElementById('uploadForm').submit();
            }, loadingTime * 1000);
        });

    </script>
    <script>
        document.getElementById('dynamic-form').addEventListener('submit', function (e) {
            e.preventDefault();
            let promoCodes = document.querySelectorAll('input[name="promo_code[]"]');
            let codes = Array.from(promoCodes).map(input => input.value.trim()); 

            let duplicateCodes = codes.filter((code, index) => codes.indexOf(code) !== index);
            if (duplicateCodes.length > 0) {
                showAlert('Duplicate Promo Code found: ' + duplicateCodes.join(', '), 'danger');
                return false;
            }

            checkPromoCodes(codes);
        });

        function checkPromoCodes(codes) {
            fetch('check_promo.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ promo_code: codes })
            })
                .then(response => response.json())
                .then(data => {
                    if (data.exists) {
                        showAlert('Promo Code(s) already exist: ' + data.ids.join(', '), 'danger');
                    } else {
                        document.getElementById('dynamic-form').submit();
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showAlert('An error occurred while checking promo codes.', 'danger');
                });
        }

        function showAlert(message, type) {
            let alertContainer = document.getElementById('alert-container');
            if (!alertContainer) {
                alertContainer = document.createElement('div');
                alertContainer.id = 'alert-container';
                document.body.insertBefore(alertContainer, document.body.firstChild);
            }

            alertContainer.innerHTML = `
        <div class="alert alert-${type} alert-dismissible fade show" role="alert" style="position: fixed;top: 0;right: 20px;transform: translateY(-50%);z-index: 1000;margin-top: 105px;width: auto;max-width: 80%;padding: 15px;font-size: 14px;border-radius: 8px;box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);background-color: #f8d7da;border-color: #f5c6cb;color: #721c24;border: 1px solid #dae0e5;border-left: solid 3px #f01e2c;box-sizing: border-box;">
            <i class="fa-solid fa-circle-exclamation" style="padding-right:3px"></i> ${message}
        </div>
    `;

            setTimeout(() => {
                let alertElement = alertContainer.querySelector('.alert');
                if (alertElement) {
                    alertElement.classList.remove('show');
                    alertElement.classList.add('fade');
                    setTimeout(() => alertContainer.innerHTML = '', 150);
                }
            }, 5000);
        }
    </script>
    <script src="../../js/file_upload.js"></script>
</body>

</html>