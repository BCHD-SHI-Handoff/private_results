$(document).ready(function() {
  // Format a date object in to mm/dd/yyyy with zero padding.
  function format_date(date) {
    var dd = date.getDate();
    var mm = date.getMonth() + 1; // January is 0
    var yyyy = date.getFullYear();
    if (dd < 10) { dd = '0' + dd }
    if (mm < 10) { mm ='0' + mm }
    return mm + '/' + dd + '/' + yyyy;
  }

  var startDateInput = $("#datepicker input[name *= 'start']")
  var endDateInput = $("#datepicker input[name *= 'end']")

  // Set our date range - 3 months ago to today.
  var today = new Date();
  var startDate = new Date();
  startDate.setMonth(startDate.getMonth() - 3)

  // Set our defaults:
  //  startDate = 1 month ago
  //  endDate = today
  var defaultStartDate = new Date();
  defaultStartDate.setMonth(defaultStartDate.getMonth() - 1)
  startDateInput.val(format_date(defaultStartDate));
  endDateInput.val(format_date(today));

  // Initialize datapicker and set our constraints and force it to open
  // below the input field (for some reason this is 'top').
  $('#datepicker').datepicker({
    startDate: startDate,
    endDate: today,
    orientation: "top auto",
    autoclose: true,
    todayHighlight: true
  });

  // XXX There's a bug in datepicker around setDate
  // See https://github.com/eternicode/bootstrap-datepicker/issues/967
  // startDateInput.datepicker('setDate', defaultStartDate);
  // endDateInput.datepicker('setDate', today);

  // Open "patients.csv?start=$end=$" when user clicks on the download CSV button.
  $('#downloadCSV').click(function() {
    startTimeStamp = startDateInput.datepicker('getDate').getTime();
    endTimeStamp = endDateInput.datepicker('getDate').getTime();
    window.location = "/admin/patients.csv?start=" + startTimeStamp + "&end=" + endTimeStamp
  });
});