$(function() {

  ace.config.set('basePath', '/assets/ace/');
  var all = document.getElementsByClassName("editor");

  for (var i=0, max=all.length; i < max; i++) {
    var editor = ace.edit(all[i]);
    editor.setTheme("ace/theme/monokai");
    editor.getSession().setMode("ace/mode/java");
    editor.setReadOnly(true);
    all[i].style.fontSize='18px';
  }

});