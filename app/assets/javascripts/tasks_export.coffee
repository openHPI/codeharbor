exportTaskStart = (taskID) ->
  $taskDiv = $('#export-task-' + taskID)
  accountLinkID = $taskDiv.attr('data-account-link')
  $messageDiv = $taskDiv.children('.import-export-message')
  $actionsDiv = $taskDiv.children('.import-export-task-actions')

  $messageDiv.html('Checking if the task exists on the external app.')
  $actionsDiv.html('<div class="spinner-border"></div>')

  $.ajax({
    type: 'POST',
    url: '/tasks/' + taskID + '/export_external_check',
    data: {account_link: accountLinkID},
    accepts: 'application/json'
    dataType: 'json',
    success: (response) ->
      $messageDiv.html(response.message)
      $actionsDiv.html(response.actions)
    error: (a, b, c) ->
      alert('error:' + c);
  })
