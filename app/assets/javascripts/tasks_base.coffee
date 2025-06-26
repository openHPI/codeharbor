ready = ->
  initializeDropdowns()

initializeDropdowns = ->
  $('.toggle-next').on 'click', ->
    $next = $(this).next()
    $next.toggleClass('hide')
    $caret = $(this).find('span.fa-solid')
    if $caret.hasClass('fa-caret-down')
      $caret.removeClass('fa-caret-down').addClass('fa-caret-up')
      $(this).removeClass('closed')
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $(this).addClass('closed')

loadComments = (url, $wait_icon, $comment_box, onSucess)->
  $.ajax({
    type: 'GET',
    url: url
    dataType: 'script'
    beforeSend: ->
      $wait_icon.removeClass('hide')
    success: ->
      $comment_box.removeClass('hide')
      if typeof onSucess == 'function'
        onSucess()
    complete: ->
      $wait_icon.addClass('hide')
  })


root = exports ? this;
root.loadComments = loadComments

$(document).on('turbo-migration:load', ready)
