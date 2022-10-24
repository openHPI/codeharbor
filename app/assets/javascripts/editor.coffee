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
    hiddenContent = $(this).parent().find('.hidden')
    editor.setTheme 'ace/theme/chrome'
    this.style.fontSize = '16px'
    if $(this).hasClass('readonly')
      editor.setReadOnly true
    else
      editor.getSession().on 'change', (e) ->
        hiddenContent.val(editor.getValue())

setAceEditorValue = (editor, value) ->
  editor = $('#task_files_attributes_6_content').parent().find('.editor')[0]
  ace.edit(editor).getSession().setValue(value)

changeEditorMode = (editor, editor_mode) ->
  ace.edit(editor).getSession().setMode(editor_mode)

getModeByFileExtension = (path) ->
  ace.require('ace/ext/modelist').getModeForPath(path).mode

$(document).on 'turbolinks:load', ready

root = exports ? this;
root.getModeByFileExtension = getModeByFileExtension
root.changeEditorMode = changeEditorMode
root.setAceEditorValue = setAceEditorValue
