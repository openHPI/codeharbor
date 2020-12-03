# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


loadFileScript =->

  $('form').on 'click', '.remove-attachment', (event) ->
    event.preventDefault()
    $(this).parent().hide()
    $(this).parents('.attachment').find('.alternative').show()
    $(this).parents('.attachment').find('.hidden-attachment-present').val(false)

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

  $('form').on 'change', '.alternative-input', (event) ->
    event.preventDefault()
    fullPath = this.value
    fullName = get_filename_from_full_path(fullPath)
#    name = fullName.split('.')[0]
#    extension = '.' + fullName.split('.')[1]
    if fullPath
#      console.log(name)
      $(this).parents('.file-container').find('.file-name').val(fullName)
#      index = $(this).parents('.file-container').find('.file-type option[data-extension="' + extension + '"]').val()
#      $(this).parents('.file-container').find('.file-type').val(index)
#      $(this).parents('.file-container').find('.file-type').trigger('change')
      
ready =->
    loadFileScript()

$(document).on('turbolinks:load', ready)
