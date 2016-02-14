var ready;
ready = function() {

  ace.config.set('basePath', '/assets/ace/');
  var all = document.getElementsByClassName("edit");

  for (var i=0, max=all.length; i < max; i++) {
    var elem = all[i].getElementsByClassName("editor")[0];
    var hidden = all[i].getElementsByClassName("hidden")[0];

    var editor = ace.edit(elem);
    editor.setTheme("ace/theme/monokai");
    editor.getSession().setMode("ace/mode/java");
    elem.style.fontSize='16px';

    initACE(editor,hidden);
  }

  var all = document.getElementsByClassName("editor_readonly");
  for (var i=0, max=all.length; i < max; i++) {
    var editor = ace.edit(all[i]);
    editor.setTheme("ace/theme/chrome");
    editor.getSession().setMode("ace/mode/java");
    editor.setReadOnly(true);
    all[i].style.fontSize='14px';
  }

  $("#addFileButton").click(function() {
    setTimeout(function() {
      $(ready);
    }, 10);
  });

  $("#addTestButton").click(function() {
    setTimeout(function() {
      $(ready);
    }, 10);
  });

};

function initACE(editor,hidden) {
  editor.getSession().on('change', function(e) {
    hidden.value=editor.getValue();
  });
}



$(document).ready(ready);
$(document).on('page:load', ready);
