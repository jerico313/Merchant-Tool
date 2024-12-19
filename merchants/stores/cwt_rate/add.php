<?php include ("../../../header.php") ?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';
$store_id = isset($_GET['store_id']) ? $_GET['store_id'] : '';
?>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($store_name); ?> - Add CWT Rate</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/papaparse@5.3.0/papaparse.min.js"></script>
    <link rel="stylesheet" href="../../../style.css">
    <style>
        body {
            background-image: url("../../../images/bg_booky.png");
        }
    </style>
</head>

<body>
    <div class="cont">
        <div class="custom-box pt-4">
            <a href="javascript:history.back()">
                <span class="back">
                    <i class="fa-regular fa-circle-left fa-lg"></i>
                    <span class="back-text"> Back to CWT Rates</span>
                </span>
            </a>
            <div class="upload pt-4" style="text-align:left;">
                <div class="add-btns">
                    <p class="title">CWT Rate Details</p>
                    <button type="button" class="btn btn-primary check-report" id="add-field">
                        <i class="fa-solid fa-plus"></i> Add More 
                    </button>
                </div>

                <div class="content">
                    <form id="dynamic-form" action="add_process.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>&store_id=<?php echo htmlspecialchars($store_id); ?>&store_name=<?php echo htmlspecialchars($store_name); ?>" method="POST">
                        <div id="form-fields">
                            <div class="form-group">
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="store_name" class="form-label" id="form-input-label">
                                                Store Name<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="text" class="form-control"
                                                style="background-color: #d3d3d3; caret-color: transparent;"
                                                value="<?php echo htmlspecialchars($store_name); ?>"
                                                name="store_name[]" readonly required>
                                            <input id="form-input-field" type="hidden" class="form-control"
                                                value="<?php echo htmlspecialchars($store_id); ?>"
                                                name="store_id[]" readonly required>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="cwt_rate" class="form-label" id="form-input-label">
                                                CWT Rate<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <div class="input-group">
                                                <input id="form-input-field" type="number" class="form-control"
                                                    name="cwt_rate[]" step="0.01" min="0.00" placeholder="0.00" id="cwt_rate" required>
                                                <span class="input-group-text">%</span>
                                            </div>                                            
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="effective_date" class="form-label" id="form-input-label">
                                                Effective Date<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="date" class="form-control"
                                                name="effective_date[]" id="effective_date" required>
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

    <script>
        document.getElementById('add-field').addEventListener('click', function () {
            var formFields = document.getElementById('form-fields');
            var newField = document.createElement('div');
            newField.classList.add('form-group');
            newField.innerHTML = `
                <div class="row">
                    <hr style="border: 1px solid #3b3b3b;">
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="store_name" class="form-label" id="form-input-label">
                                Store Name<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="form-input-field" type="text" class="form-control"
                                style="background-color: #d3d3d3; caret-color: transparent;"
                                value="<?php echo htmlspecialchars($store_name); ?>"
                                name="store_name[]" readonly required>
                            <input id="form-input-field" type="hidden" class="form-control"
                                value="<?php echo htmlspecialchars($store_id); ?>"
                                name="store_id[]" readonly required>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="cwt_rate" class="form-label" id="form-input-label">
                                CWT Rate<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <div class="input-group">
                                <input id="form-input-field" type="number" class="form-control"
                                    name="cwt_rate[]" step="0.01" min="0.00" placeholder="0.00" id="cwt_rate" required>
                                <span class="input-group-text">%</span>
                            </div>                                            
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="effective_date" class="form-label" id="form-input-label">
                                Effective Date<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="form-input-field" type="date" class="form-control"
                                name="effective_date[]" id="effective_date" required>
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
        document.addEventListener('click', function (e) {
            if (e.target && e.target.classList.contains('remove-field')) {
                e.target.closest('.form-group').remove();
            }
        });
    </script>
</body>
</html>