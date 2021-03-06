ready =->
  initializeAce()
  initializeEditors()

initializeAce = ->
  ace.config.set 'basePath', '/assets/ace/'
  $(document).on 'fields_added.nested_form_fields', ->
    $ initializeEditors()

initializeEditors =->
  $('.editor').each ->
    editor = ace.edit(this)
    editor.setTheme 'ace/theme/chrome'
    this.style.fontSize = '16px'
    if $(this).hasClass('readonly')
      editor.setReadOnly true
    else
      editor.getSession().on 'change', (e) ->
        $(this).parent().find('.hidden').val(editor.getValue())

changeEditorMode = (editor, editor_mode) ->
  ace.edit(editor).getSession().setMode(editor_mode)

getModeByFileExtension = (path) ->
  ace.require('ace/ext/modelist').getModeForPath(path).mode

$(document).on 'turbolinks:load', ready

root = exports ? this;
root.getModeByFileExtension = getModeByFileExtension
root.changeEditorMode = changeEditorMode
