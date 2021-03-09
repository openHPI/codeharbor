ready =->
  initializeUploadedFileDeletion()
  initializeToggleEditorAttachment()
  initializeSetNameOnUpload()

$(document).on('turbolinks:load', ready)

initializeUploadedFileDeletion =->
  $('form').on 'click', '.remove-attachment', (event) ->
    event.preventDefault()
    $(this).parent().hide()
    $(this).parents('.attachment').find('.alternative').show()
    $(this).parents('.attachment').find('.hidden-attachment-present').val(false)

initializeToggleEditorAttachment =->
  $('form').on 'click','.toggle-input', (event) ->
    event.preventDefault()
    $content = $(this).next()
    $editor = $content.find('.edit')
    $attachment = $content.find('.attachment')

    if ($attachment.css('display') == 'none')
      $(this).text($(this).data('text-toggled'))
      $editor.find('.hidden').attr('disabled', true)
      $editor.hide()
      $attachment.find('.alternative-input').attr('disabled', false)
      $attachment.show()
    else
      $(this).text($(this).data('text-initial'))
      $attachment.find('.alternative-input').attr('disabled', true)
      $attachment.hide()
      $editor.find('hidden').attr('disabled', false)
      $editor.show()
    return

initializeSetNameOnUpload =->
  $('form').on 'change', '.alternative-input', (event) ->
    event.preventDefault()
    fullPath = this.value
    fullName = get_filename_from_full_path(fullPath)
    if fullPath
      $(this).parents('.file-container').find('.file-name').val(fullName)
