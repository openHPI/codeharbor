ready =->
  setAceEditorMode()

$(document).on('turbolinks:load', ready)

setAceEditorMode =->
  $('.editor.readonly').each ->
    changeEditorMode(this, getModeByFileExtension($(this).data('file-name')))
