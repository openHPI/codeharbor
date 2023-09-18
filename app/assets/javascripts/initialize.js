$(document).on('turbolinks:load', function () {
  $('[data-bs-toggle="tooltip"]').tooltip();
  // Ensure that the tab button will be in active (selected) state for each page that has 'option' query (e.g. groups or messages page)
  $('#' + $('#option').val()).addClass('selected');
});
