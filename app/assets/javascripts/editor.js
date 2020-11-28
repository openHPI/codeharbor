var ready;
ready = function() {

  ace.config.set('basePath', '/assets/ace/');
  var all = document.getElementsByClassName("edit");

  for (var i=0, max=all.length; i < max; i++) {
    var elem = all[i].getElementsByClassName("editor")[0];
    var formElement = all[i].getElementsByClassName("hidden")[0];

    var editor = ace.edit(elem);
    editor.setTheme("ace/theme/chrome");
    editor.getSession().setMode("ace/mode/java");
    elem.style.fontSize='16px';

    initACE(editor, formElement);
  }

  var all = document.getElementsByClassName("editor_readonly");
  for (var i=0, max=all.length; i < max; i++) {
    var editor = ace.edit(all[i]);
    editor.setTheme("ace/theme/chrome");
    var mode = $(all[i]).attr('data-editor-mode');
    editor.getSession().setMode(mode);
    editor.setReadOnly(true);
    all[i].style.fontSize='14px';
  }
  $(document).on("fields_added.nested_form_fields", function () {
    $(ready);
  })

};

function initACE(editor,hidden) {
  editor.getSession().on('change', function(e) {
    hidden.value=editor.getValue();
  });
}

$(document).on('turbolinks:load', ready);
