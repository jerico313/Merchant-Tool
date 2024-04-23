    function editTutuban(scheduleId) {
    // Fetch the current data of the selected schedule
    var scheduleTime = $('#dynamicTableBodyTutuban').find('tr[data-id="' + scheduleId + '"] td:nth-child(2)').text();
    var scheduleStatus = $('#dynamicTableBodyTutuban').find('tr[data-id="' + scheduleId + '"] td:nth-child(3)').text();
    var scheduleDirection = $('#dynamicTableBodyTutuban').find('tr[data-id="' + scheduleId + '"] td:nth-child(4)').text();

    // Split the time to get hour, minute, and period
    var timeComponents = scheduleTime.split(' ');
    var hourMinute = timeComponents[0].split(':');
    var hour = hourMinute[0];
    var minute = hourMinute[1];
    var period = timeComponents[1];

    // Set values in the edit modal
    $('#editScheduleId').val(scheduleId);
    $('#edithour').val(hour);
    $('#editminute').val(minute);
    $('#editperiod').val(period);
    $('#editstatus').val(scheduleStatus);
    $('#editdirection').val(scheduleDirection);

    // Open the edit modal
    $('#editModalTutuban').modal('show');
}

function deleteTutuban(scheduleId) {
    // Set the schedule ID to be deleted
    $('#deleteScheduleId').val(scheduleId);
    // Open the delete confirmation modal
    $('#deleteModalTutuban').modal('show');
}

function confirmDeleteTutuban() {
    // Get the schedule ID to be deleted
    var scheduleId = $('#deleteScheduleId').val();

    // Add logic for deleting a schedule
    $.ajax({
        url: 'delete_schedule.php',
        method: 'POST',
        data: { scheduleId: scheduleId },
        success: function(response) {
    // Log the response from the server
    console.log(response);

    // Parse the JSON response
    var jsonResponse = JSON.parse(response);

    // Check if the deletion was successful
    if (jsonResponse.success) {
        // If deletion is successful, remove the row from the table
        location.reload(); // Reload the page or remove the row using jQuery
    } else {
        // If there's an error, show an alert with the error message
        alert('Error: ' + jsonResponse.message);
    }

    // Close the delete confirmation modal
    $('#deleteModalTutuban').modal('hide');
},

    });
}
