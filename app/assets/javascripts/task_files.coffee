ready = ->
  initializeUploadedFileReupload()
  initializeUploadedFileChange()
  initializeToggleEditorAttachment()
  initializeOnUpload()
  initializeExtractText()

initializeUploadedFileChange = ->
  $('form').on 'change', '.alternative-input', (event) ->
    $(this).parents('.attachment').find('.alternative').removeClass('hide')
    $(this).parents('.attachment').find('.attachment_present').addClass('hide')

initializeUploadedFileReupload = ->
  $('form').on 'click', '.reupload-attachment', (event) ->
    event.preventDefault()
    $(this).parents('.attachment').find('.alternative-input').click()

initializeExtractText = ->
  $('form').on 'click', '.extract-text', (event) ->
    $button = $(this)
    id = $button.data('file-id')
    $.ajax
      type: 'GET'
      url: Routes.extract_text_data_task_file_path(id)
      success: (response) ->
        $content = $button.parents('.toggle-divs')
        hideFileUploadShowTextEditor $content, response.text_data

initializeToggleEditorAttachment = ->
  $('form').on 'click', '.toggle-input', (event) ->
    event.preventDefault()
    $content = $(this).next()
    $attachment = $content.find('.attachment')

    if $attachment.hasClass('hide')
      showFileUploadHideTextEditor $content
    else
      hideFileUploadShowTextEditor $content
    return

showFileUploadHideTextEditor = ($content) ->
  $editor = $content.find('.edit')
  $attachment = $content.find('.attachment')
  $editor.find('.d-none').attr('disabled', true)
  $editor.addClass('hide')
  $attachment.find('.use-attached-file').val(true)
  $attachment.find('.alternative-input').attr('disabled', false)
  $attachment.removeClass('hide')

hideFileUploadShowTextEditor = ($content, text) ->
  $editor = $content.find('.edit')
  $ace_editor = $content.find('.editor')
  $attachment = $content.find('.attachment')
  $attachment.find('.alternative-input').attr('disabled', true)
  $attachment.find('.use-attached-file').val(false)
  $attachment.addClass('hide')
  $editor.find('.d-none').attr('disabled', false)
  $editor.removeClass('hide')
  if text
    setAceEditorValue $ace_editor[0], text

initializeOnUpload = ->
  $('form').on 'change', '.alternative-input', (event) ->
    $(this).parents('.attachment').find('.use-attached-file').val(true)
    event.preventDefault()
    fullPath = this.value
    fullName = get_filename_from_full_path(fullPath)
    if fullPath
      $(this).parents('.file-container').find('.file-name').val(fullName)

$(document).on 'turbo-migration:load', ready
