ready =->
  initializeExportActions()

$(document).on('turbolinks:load', ready)


initializeExportActions =->
  $('body').on 'click', '.export-action', (event) ->
    exportType = $(this).attr('data-export-type')
    taskId = $(this).parents('.import-export-task').attr('data-task-id')
    accountLinkId = $(this).parents('.import-export-task').attr('data-account-link')
    exportConfirm(taskId, accountLinkId, exportType)


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
    error: (_, _, message) ->
      alert('error:' + message);
  })

exportConfirm = (taskId, accountLinkId, pushType) ->
  $taskDiv = $('#export-task-' + taskId)
  $messageDiv = $taskDiv.children('.import-export-message')
  $actionsDiv = $taskDiv.children('.import-export-task-actions')

  $.ajax({
    type: 'POST',
    url: '/tasks/' + taskId + '/export_external_confirm',
    data: {account_link: accountLinkId, push_type: pushType},
    dataType: 'json',
    success: (response) ->
      $messageDiv.html response.message
      $actionsDiv.html response.actions

      if response.status == 'success'
        $taskDiv.addClass 'import-export-success'
      else
        $taskDiv.addClass 'import-export-failure'
    error: (_, _, message) ->
      alert('error:' + message)
  })

root = exports ? this;
root.exportTaskStart = exportTaskStart
