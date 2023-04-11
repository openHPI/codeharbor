ready =->
  initializeLoadSelect2()
  initializeFileTypeSelection()

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
    placeholder: I18n.t('tasks.edit.select_groups')

initializeFileTypeSelection = ->
  $('body').on 'keyup', '.file-name', (event) ->
    editor = $(this).parents('.file-container').find('.editor')[0]
    changeEditorMode(editor, getModeByFileExtension($(this).val()))
  $('.file-name').keyup()
