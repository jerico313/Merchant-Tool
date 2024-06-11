    document.getElementById('fileToUpload').addEventListener('change', function () {
    const filenameElement = document.querySelector('.filename');
    const filename = this.files[0].name;
    filenameElement.textContent = `${filename}`;

    // Preview the file content
    const previewArea = document.querySelector('.file-preview');
    previewArea.innerHTML = ''; // Clear previous preview
    const file = this.files[0];

    if (file.type === 'application/vnd.ms-excel' || file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || file.name.endsWith('.csv')) {
        Papa.parse(file, {
            header: true,
            dynamicTyping: true,
            complete: function(results) {
                const data = results.data;
                const table = document.createElement('table');
                table.classList.add('table', 'table-bordered', 'table-striped', 'mt-3', 'mb-5', 'table-transparent');
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

    document.getElementById('clearButton').addEventListener('click', function() {
        const fileInput = document.getElementById('fileToUpload');
        fileInput.value = ''; // Clear file input
        document.querySelector('.filename').textContent = ''; // Clear filename display
        document.querySelector('.file-preview').innerHTML = ''; // Clear file preview
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

    