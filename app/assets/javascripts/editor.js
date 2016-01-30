var ready;
ready = function() {

  ace.config.set('basePath', '/assets/ace/');
  var all = document.getElementsByClassName("edit");

  for (var i=0, max=all.length; i < max; i++) {
    var elem = all[i].getElementsByClassName("editor")[0];
    var editor = ace.edit(elem);
    editor.setTheme("ace/theme/monokai");
    editor.getSession().setMode("ace/mode/java");
    //editor.setReadOnly(true);
    elem.style.fontSize='18px';

    editor.getSession().on('change', function(e) {
      alert(editor.getValue());
    // e.type, etc
    });
  }

};

$(document).ready(ready);
$(document).on('page:load', ready);
