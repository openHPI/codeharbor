ready = ->
  initializeFileTypeSelection()
  initializeVisibilityWarning()
  initializeRadioButtonDeselection()

initializeLoadSelect2 = ->
  $('#task_programming_language_id').select2
    language: I18n.locale
    tags: false
    width: '100%'
    multiple: false

  $('.my-group').select2
    language: I18n.locale
    width: '100%'
    multiple: true
    closeOnSelect: false
    placeholder: I18n.t('tasks.javascripts.select_groups')

  $(document).one('turbo:visit', destroy_select2);

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

initializeRadioButtonDeselection = ->
  radios = $('.radio-switch input[type="radio"][name*="[usage_by_lms]"]')
  hidden_field = $('input[name="file[usage_by_lms]"][type="hidden"]')

  radios.each ->
    $radio = $(this)
    $radio.data('was-checked', $radio.prop('checked'))

  radios.on 'click', ->
    $radio = $(this)

    if $radio.prop('checked') and $radio.data('was-checked')
      $radio.prop('checked', false).data('was-checked', false)
      hidden_field.val(null) # Reset the value to `nil`
    else
      radios.data('was-checked', false) # Reset all other radios
      $radio.data('was-checked', true)
      hidden_field.val('') # Clear hidden field since something is selected

destroy_select2 = ->
  $('#task_programming_language_id').select2('destroy');
  $('.my-group').select2('destroy');
  return

$(document).on('turbo-migration:load', ready)
$(document).on('select2:locales:loaded', initializeLoadSelect2)
