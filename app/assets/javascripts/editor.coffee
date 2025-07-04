ready = ->
  initializeAce()
  initializeEditors()

initializeAce = ->
  $(document).on 'fields_added.nested_form_fields', ->
    $ initializeEditors()

unloadEditors = (event) ->
  $('.editor').each (_, editor) ->
    aceEditor = ace.edit(editor)
    content = aceEditor.getValue();
    aceEditor.destroy()
    editor.textContent = content;
  return

initializeEditors = ->
  $('.editor').each ->
    editor = ace.edit(this)
    hiddenContent = $(this).parent().find('.d-none')
    editor.setTheme 'ace/theme/chrome'
    this.style.fontSize = '16px'
    if $(this).hasClass('readonly')
      editor.setReadOnly true
    else
      editor.getSession().on 'change', (e) ->
        hiddenContent.val(editor.getValue()).trigger('change')
  $(document).one('turbo:visit', unloadEditors);
  $(window).one('beforeunload', unloadEditors);

setAceEditorValue = (editor, value) ->
  aceEditor = $(editor).parent().find('.editor')[0]
  ace.edit(aceEditor).getSession().setValue(value)

changeEditorMode = (editor, editor_mode) ->
  ace.edit(editor).getSession().setMode(editor_mode)

getModeByFileExtension = (path) ->
  ace.require('ace/ext/modelist').getModeForPath(path).mode


root = exports ? this;
root.getModeByFileExtension = getModeByFileExtension
root.changeEditorMode = changeEditorMode
root.setAceEditorValue = setAceEditorValue

$(document).on('turbo-migration:load', ready)
