ready = ->
  setAceEditorMode()
  initializeShowComments()

setAceEditorMode = ->
  $('.editor.readonly').each ->
    changeEditorMode(this, getModeByFileExtension($(this).data('file-name')))

initializeShowComments = ->
  $('.show-comment-button').on 'click', ->
    url = Routes.task_comments_path($(this).data('task-id'))
    $comment_box = $(".comment-box")
    $caret = $(this).children('.my-caret')
    $wait_icon = $(this).children('.wait')

    if $caret.hasClass('fa-caret-down')
      $caret.removeClass('fa-caret-down').addClass('fa-caret-up')
      loadComments(url, $wait_icon, $comment_box, ->
        document.getElementById('page_end').scrollIntoView(false))
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $comment_box.addClass('hide')


$(document).on('turbo-migration:load', ready)
