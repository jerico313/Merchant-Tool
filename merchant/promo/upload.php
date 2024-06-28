<?php include ("../../header.php") ?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
?>
<!DOCTYPE html>
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
            <a href="javascript:history.back()">
                <span class="back"><i class="fa-regular fa-circle-left fa-lg"></i></span>
            </a>
            <div class="upload pt-3" style="text-align:left;">
                <div class="add-btns">
                    <p class="title">Upload Promo</p>
                    <button type="button" class="btn btn-warning check-report" id="addStoreBtn"><i
                            class="fa-solid fa-plus"></i> Add New Promo </button>
                    <form id="uploadForm" action="upload_process.php" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="merchant_id" value="<?php echo htmlspecialchars($merchant_id); ?>">
                        <input type="hidden" name="merchant_name"
                            value="<?php echo htmlspecialchars($merchant_name); ?>">
                </div>

                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;">
                    <div class="file" style="padding:10px 10px 10px 0;font-size:15px;">
                        <p style="font-weight:bold;">Selected File: <span class="filename" style="color:#E96529"></span>
                        </p>
                    </div>
                    <label for="fileToUpload" style="background-color:#fff;font-size:20px;" class="upload-btn"
                        id="uploadBtn"><i class="fa-solid fa-cloud-arrow-up fa-2xl"
                            style="font-size:40px;padding-bottom:30px;"></i><br>Choose a File or Drag it
                        here </label>
                    <input type="file" name="fileToUpload" id="fileToUpload" accept=".csv" style="display:none;">
                    <div class="uploadfile" style="text-align:right;">
                        <button type="button" class="btn btn-danger clear" id="clearButton">Clear</button>
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
        </div>
    </div>

    <div class="form" style="text-align:left;display:none;">
        <div class="add-btns pt-3">
            <p class="title">Promo Details</p>
            <button type="button" class="btn btn-warning check-report" id="uploadStoreBtn"><i
                    class="fa-solid fa-upload"></i> Upload Promo </button>
            <button type="button" class="btn btn-success" id="add-field"><i class="fa-solid fa-plus"></i> Add More
            </button>
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
                                        style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_name" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Merchant Name</label>
                                    <input type="text" class="form-control"
                                        value="<?php echo htmlspecialchars($merchant_name); ?>" name="merchant_name[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;background-color:#d3d3d3;"
                                        readonly required>
                                    <input type="hidden" class="form-control"
                                        value="<?php echo htmlspecialchars($merchant_id); ?>" name="merchant_id[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;background-color:#d3d3d3;"
                                        readonly required>

                                </div>
                                <div class="mb-3">
                                    <label for="promo_amount" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Promo Amount</label>
                                    <input type="text" class="form-control" name="promo_amount[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="voucher_type" class="form-label" style="font-size:15px;font-weight:bold;">Voucher Type</label>
                                    <select class="form-select" id="voucher_type" name="voucher_type[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Voucher Type --</option>
                                        <option value="Coupled">Coupled</option>
                                        <option value="Decoupled">Decoupled</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_category" class="form-label" style="font-size:15px;font-weight:bold;">Promo Category</label>
                                    <select class="form-select" id="promo_category" name="promo_category[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Promo Category --</option>
                                        <option value="Grab & Go">Grab & Go</option>
                                        <option value="Casual Dining">Casual Dining</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_group" class="form-label" style="font-size:15px;font-weight:bold;">Promo Group</label>
                                    <select class="form-select" id="promo_group" name="promo_group[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Promo Group --</option>
                                        <option value="Grab & Go">Booky</option>
                                        <option value="Gcash">Gcash</option>
                                        <option value="Unionbank">Unionbank</option>
                                        <option value="Gcash/Booky">Gcash/Booky</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_type" class="form-label" style="font-size:15px;font-weight:bold;">Promo Type</label>
                                    <select class="form-select" id="promo_type" name="promo_type[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
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
                                        <textarea class="form-control" rows="5" name="promo_details[]" style="border-radius:20px;padding:15px 15px;border:none;" required></textarea>
                                </div>
                                <div class="mb-3">
                                    <label for="remarks" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Remarks</label>
                                    <input type="text" class="form-control" name="remarks[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;">
                                </div>
                            <div class="mb-3">
                                <label for="bill_status" class="form-label" style="font-size:15px;font-weight:bold;">Bill Status</label>
                                <select class="form-select" id="bill_status" name="bill_status[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                    <option value="">-- Select Bill Status --</option>
                                    <option value="PRE-TRIAL">PRE-TRIAL</option>
                                    <option value="BILLABLE">BILLABLE</option>
                                    <option value="NOT BILLABLE">NOT BILLABLE</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="start_date" class="form-label" style="font-size:15px;font-weight:bold;">Start Date</label>
                                <input type="date" class="form-control" id="start_date" name="start_date[]" style="border-radius:20px;padding:11px 20px;border:none;">
                            </div>
                            <div class="mb-3">
                                <label for="end_date" class="form-label" style="font-size:15px;font-weight:bold;">End Date</label>
                                <input type="date" class="form-control" id="end_date" name="end_date[]" style="border-radius:20px;padding:11px 20px;border:none;">
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

    <script src="../../js/file_upload.js"></script>
    <script>
        // Add event listeners to buttons
        document.getElementById('addStoreBtn').addEventListener('click', function () {
            document.querySelector('.form').style.display = 'block';
            document.querySelector('.upload').style.display = 'none';
        });

        document.getElementById('uploadStoreBtn').addEventListener('click', function () {
            document.querySelector('.form').style.display = 'none';
            document.querySelector('.upload').style.display = 'block';
        });

        document.addEventListener("DOMContentLoaded", function () {
            // Trigger input event to generate form for default value
            document.getElementById('StoreNum').dispatchEvent(new Event('input'));
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
                                    <label for="promo_id" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Promo Code</label>
                                    <input type="text" class="form-control" name="promo_code[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="merchant_name" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Merchant Name</label>
                                    <input type="text" class="form-control"
                                        value="<?php echo htmlspecialchars($merchant_name); ?>" name="merchant_name[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;background-color:#d3d3d3;"
                                        readonly required>
                                    <input type="hidden" class="form-control"
                                        value="<?php echo htmlspecialchars($merchant_id); ?>" name="merchant_id[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;background-color:#d3d3d3;"
                                        readonly required>

                                </div>
                                <div class="mb-3">
                                    <label for="promo_amount" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Promo Amount</label>
                                    <input type="text" class="form-control" name="promo_amount[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;" required>
                                </div>
                                <div class="mb-3">
                                    <label for="voucher_type" class="form-label" style="font-size:15px;font-weight:bold;">Voucher Type</label>
                                    <select class="form-select" id="voucher_type" name="voucher_type[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Voucher Type --</option>
                                        <option value="Coupled">Coupled</option>
                                        <option value="Decoupled">Decoupled</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_category" class="form-label" style="font-size:15px;font-weight:bold;">Promo Category</label>
                                    <select class="form-select" id="promo_category" name="promo_category[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Promo Category --</option>
                                        <option value="Grab & Go">Grab & Go</option>
                                        <option value="Casual Dining">Casual Dining</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_group" class="form-label" style="font-size:15px;font-weight:bold;">Promo Group</label>
                                    <select class="form-select" id="promo_group" name="promo_group[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                        <option value="">-- Select Promo Group --</option>
                                        <option value="Grab & Go">Booky</option>
                                        <option value="Gcash">Gcash</option>
                                        <option value="Unionbank">Unionbank</option>
                                        <option value="Gcash/Booky">Gcash/Booky</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="promo_type" class="form-label" style="font-size:15px;font-weight:bold;">Promo Type</label>
                                    <select class="form-select" id="promo_type" name="promo_type[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
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
                                        <textarea class="form-control" rows="5" name="promo_details[]" style="border-radius:20px;padding:15px 15px;border:none;" required></textarea>
                                </div>
                                <div class="mb-3">
                                    <label for="remarks" class="form-label"
                                        style="font-size:15px;font-weight:bold;">Remarks</label>
                                    <input type="text" class="form-control" name="remarks[]"
                                        style="border-radius:20px;padding:10px 20px;border:none;">
                                </div>
                            <div class="mb-3">
                                <label for="bill_status" class="form-label" style="font-size:15px;font-weight:bold;">Bill Status</label>
                                <select class="form-select" id="bill_status" name="bill_status[]" style="border-radius:20px;padding:11px 20px;border:none;" required>
                                    <option value="">-- Select Bill Status --</option>
                                    <option value="PRE-TRIAL">PRE-TRIAL</option>
                                    <option value="BILLABLE">BILLABLE</option>
                                    <option value="NOT BILLABLE">NOT BILLABLE</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="start_date" class="form-label" style="font-size:15px;font-weight:bold;">Start Date</label>
                                <input type="date" class="form-control" id="start_date" name="start_date[]" style="border-radius:20px;padding:11px 20px;border:none;">
                            </div>
                            <div class="mb-3">
                                <label for="end_date" class="form-label" style="font-size:15px;font-weight:bold;">End Date</label>
                                <input type="date" class="form-control" id="end_date" name="end_date[]" style="border-radius:20px;padding:11px 20px;border:none;">
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
    </script>
</body>

</html>