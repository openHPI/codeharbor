ready =->
  initializeLoadSelect2()
  initializeFileTypeSelection()
  initializeVisibilityWarning()

$(document).on('turbolinks:load', ready)

initializeLoadSelect2 = ->
  $('#task_programming_language_id').select2
    tags: false
    width: '100%'
    multiple: false

  $('.my-group').select2
    width: '100%'
    multiple: true
    closeOnSelect: false
    placeholder: I18n.t('javascripts.tasks_form.select_groups')

initializeFileTypeSelection = ->
  $('body').on 'keyup', '.file-name', (event) ->
    editor = $(this).parents('.file-container').find('.editor')[0]
    changeEditorMode(editor, getModeByFileExtension($(this).val()))
  $('.file-name').keyup()

initializeVisibilityWarning = ->
  warning_message = $('#task_visibility_warning')
  $('#task_access_level_private').on 'change', ->
    if warning_message.data("external-collection-membership")
      warning_message.removeClass('d-none')
  $('#task_access_level_public').on 'change', ->
      warning_message.addClass('d-none')
