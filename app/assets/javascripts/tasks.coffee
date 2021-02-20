ready = ->
  $('body').on 'change', '.file-name', (event) ->
    editor = $(this).parents('.file-container').find('.editor')[0]

    changeEditorMode(editor, getModeByFileExtension($(this).val()))

changeEditorMode = (editor, editor_mode) ->
  ace.edit(editor).getSession().setMode(editor_mode)

getModeByFileExtension = (path) ->
  ace.require('ace/ext/modelist').getModeForPath(path).mode

$(document).on('turbolinks:load', ready)
