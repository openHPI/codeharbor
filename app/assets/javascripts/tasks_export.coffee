ready = ->
  initializeExportActions()

initializeExportActions = ->
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

  $messageDiv.html(I18n.t('tasks.javascripts.checking_external_app'))
  $actionsDiv.html('<div class="spinner-border"></div>')

  $.ajax({
    type: 'POST',
    url: Routes.export_external_check_task_path(taskID),
    data: {account_link: accountLinkID},
    dataType: 'json',
    success: (response) ->
      $messageDiv.html(response.message)
      $actionsDiv.html(response.actions)
    error: (_xhr, _textStatus, message) ->
      alert("#{I18n.t('common.javascripts.error')}: #{message}");
  })

exportConfirm = (taskId, accountLinkId, pushType) ->
  $taskDiv = $('#export-task-' + taskId)
  $messageDiv = $taskDiv.children('.import-export-message')
  $actionsDiv = $taskDiv.children('.import-export-task-actions')

  $.ajax({
    type: 'POST',
    url: Routes.export_external_confirm_task_path(taskId),
    data: {account_link: accountLinkId, push_type: pushType},
    dataType: 'json',
    success: (response) ->
      $messageDiv.html response.message
      $actionsDiv.html response.actions

      if response.status == 'success'
        $taskDiv.addClass 'import-export-success'
      else
        $taskDiv.addClass 'import-export-failure'
    error: (_xhr, _textStatus, message) ->
      alert("#{I18n.t('common.javascripts.error')}: #{message}")
  })


root = exports ? this;
root.exportTaskStart = exportTaskStart

$(document).on('turbo-migration:load', ready)
