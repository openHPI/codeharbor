ready = ->
  console.log 'ready'
  $('body').on 'change', '.file-name', (event) ->
    console.log 'change'
    editor = $(this).parents('.file-container').find('.editor')[0]

    changeEditorMode(editor, ace.require('ace/ext/modelist').getModeForPath($(this).val()).mode)

changeEditorMode = (editor, editor_mode) ->
#  editor = $(element).parents('.file-container').find('.editor')[0]
#  mode = $(element).find('option:selected').attr('data-editor-mode')
  ace.edit(editor).getSession().setMode(editor_mode)

getModeByFileExtension = (path) ->
  ace.require('ace/ext/modelist').getModeForPath(path).mode

$(document).on('turbolinks:load', ready)
