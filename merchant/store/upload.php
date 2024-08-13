<?php include ("../../header.php") ?>
<?php
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
?>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Store</title>
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
                    <span class="back-text"> Back to Stores</span>
                </span>
            </a>
            <div class="upload pt-4" style="text-align:left;">
                <div class="add-btns">
                    <p class="title">Store Details</p>
                    <button type="button" class="btn btn-primary check-report" id="add-field">
                        <i class="fa-solid fa-plus"></i> Add More 
                    </button>
                </div>

                <div class="content">
                    <form id="dynamic-form" action="add.php?merchant_id=<?php echo htmlspecialchars($merchant_id); ?>&merchant_name=<?php echo htmlspecialchars($merchant_name); ?>" method="POST">
                        <div id="form-fields">
                            <div class="form-group">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="store_id" class="form-label" id="form-input-label">
                                                Store ID<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="text" class="form-control" 
                                                name="store_id[]" placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                                                required maxlength="36">
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
                                            <label for="store_name" class="form-label" id="form-input-label">
                                                Store Name<span class="text-danger" style="padding:2px">*</span>
                                            </label>
                                            <input id="form-input-field" type="text" class="form-control" 
                                                name="store_name[]" placeholder="Enter store name"
                                                required maxlength="255">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="legal_entity_name" class="form-label" id="form-input-label">Legal Entity Name</label>
                                            <input id="form-input-field" type="text" class="form-control" 
                                                name="legal_entity_name[]" placeholder="Enter legal entity name"
                                                maxlength="255">
                                        </div>
                                        <div class="mb-3">
                                            <label for="store_address" class="form-label" id="form-input-label">Store Address</label>
                                            <textarea id="form-input-field" class="form-control" rows="1" 
                                                name="store_address[]" placeholder="Enter store address"></textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label for="email_address" class="form-label" id="form-input-label">Email Address</label>
                                            <textarea id="form-input-field" class="form-control" rows="1" 
                                                name="email_address[]" placeholder="Enter email address"></textarea>
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
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="store_id" class="form-label" id="form-input-label">
                                Store ID<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="form-input-field" type="text" class="form-control" 
                                name="store_id[]" placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                                required maxlength="36">
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
                            <label for="store_name" class="form-label" id="form-input-label">
                                Store Name<span class="text-danger" style="padding:2px">*</span>
                            </label>
                            <input id="form-input-field" type="text" class="form-control" 
                                name="store_name[]" placeholder="Enter store name"
                                required maxlength="255">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="legal_entity_name" class="form-label" id="form-input-label">Legal Entity Name</label>
                            <input id="form-input-field" type="text" class="form-control" 
                                name="legal_entity_name[]" placeholder="Enter legal entity name"
                                maxlength="255">
                        </div>
                        <div class="mb-3">
                            <label for="store_address" class="form-label" id="form-input-label">Store Address</label>
                            <textarea id="form-input-field" class="form-control" rows="1" 
                                name="store_address[]" placeholder="Enter store address"></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="email_address" class="form-label" id="form-input-label">Email Address</label>
                            <textarea id="form-input-field" class="form-control" rows="1" 
                                name="email_address[]" placeholder="Enter email address"></textarea>
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
    <script>
document.getElementById('dynamic-form').addEventListener('submit', function (e) {
    e.preventDefault();
    let storeIds = document.querySelectorAll('input[name="store_id[]"]');
    let ids = Array.from(storeIds).map(input => input.value.trim());

    let duplicateIds = ids.filter((id, index) => ids.indexOf(id) !== index);
    if (duplicateIds.length > 0) {
        showAlert('Duplicate Store ID found: ' + duplicateIds.join(', '), 'danger');
        return false;
    }

    checkStoreIds(ids);
});

function checkStoreIds(ids) {
    fetch('check_store.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ store_ids: ids })
    })
    .then(response => response.json())
    .then(data => {
        if (data.exists) {
            showAlert('Store IDs already exist: ' + data.ids.join(', '), 'danger');
        } else {
            document.getElementById('dynamic-form').submit();
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showAlert('An error occurred while checking store IDs.', 'danger');
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

</body>
</html>