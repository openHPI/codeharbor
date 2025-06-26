ready = ->
  initializeImport()

initializeImport = ->
  $('#xml-import').on 'click', (e) ->
    e.stopPropagation()

  $('#import-task-button').on 'click', (e) ->
    e.preventDefault()
    e.stopPropagation()
    importStart()

  $('body').on 'click', '.export-close-button', (event) ->
    $(this).parents('.import-export-task').remove()

  $('#task_import').on 'change', ->
    fullPath = document.getElementById('task_import').value
    if fullPath
      document.getElementById('file-label').innerHTML = get_filename_from_full_path(fullPath)

  $('body').on 'click', '.import-action', (event) ->
    importId = $(this).parents('.import-export-task').attr('data-import-id')
    subfileId = $(this).parents('.import-export-task').attr('data-import-subfile-id')
    importType = $(this).attr('data-import-type')
    importConfirm(importId, subfileId, importType)

importStart = () ->
  formData = new FormData()
  formData.append('zip_file', document.getElementById('task_import').files[0])

  $.ajax({
    type: 'POST',
    url: Routes.import_start_tasks_path(),
    data: formData,
    processData: false,
    contentType: false,
    error: (_xhr, _textStatus, message) ->
      alert("#{I18n.t('common.javascripts.error')}: #{message}")
  })

importConfirm = (importId, subfileId, importType) ->
  $taskDiv = $('[data-import-subfile-id=' + subfileId + ']')
  $messageDiv = $taskDiv.children('.import-export-message')
  $actionsDiv = $taskDiv.children('.import-export-task-actions')

  $.ajax({
    type: 'POST',
    url: Routes.import_confirm_tasks_path(),
    data: {import_id: importId, subfile_id: subfileId, import_type: importType},
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


$(document).on('turbo-migration:load', ready)
