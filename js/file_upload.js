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
                    th.textContent = key.toUpperCase(); 
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

    document.getElementById('clearButton').addEventListener('click', function() {
        const fileInput = document.getElementById('fileToUpload');
        fileInput.value = ''; // Clear file input
        document.querySelector('.filename').textContent = ''; // Clear filename display
        document.querySelector('.file-preview').innerHTML = ''; // Clear file preview
    });

    