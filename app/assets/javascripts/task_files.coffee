ready =->
  initializeUploadedFileReupload()
  initializeUploadedFileChange()
  initializeToggleEditorAttachment()
  initializeOnUpload()

$(document).on('turbolinks:load', ready)

initializeUploadedFileChange =->
  $('form').on 'change', '.alternative-input', (event) ->
    $(this).parents('.attachment').find('.alternative').show()
    $(this).parents('.attachment').find('.attachment_present').hide()


initializeUploadedFileReupload =->
  $('form').on 'click', '.reupload-attachment', (event) ->
    event.preventDefault()
    $(this).parents('.attachment').find('.alternative-input').click()

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
      $attachment.find('.use-attached-file').val(true)
      $attachment.find('.alternative-input').attr('disabled', false)
      $attachment.show()
    else
      $(this).text($(this).data('text-initial'))
      $attachment.find('.alternative-input').attr('disabled', true)
      $attachment.find('.use-attached-file').val(false)
      $attachment.hide()
      $editor.find('.hidden').attr('disabled', false)
      $editor.show()
    return

initializeOnUpload =->
  $('form').on 'change', '.alternative-input', (event) ->
    $(this).parents('.attachment').find('.use-attached-file').val(true)
    event.preventDefault()
    fullPath = this.value
    fullName = get_filename_from_full_path(fullPath)
    if fullPath
      $(this).parents('.file-container').find('.file-name').val(fullName)
