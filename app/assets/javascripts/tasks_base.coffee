ready =->
  initializeDropdowns()

$(document).on('turbolinks:load', ready)

initializeDropdowns =->
  $('.toggle-next').on 'click', ->
    $next = $(this).next()
    $next.toggle()
    $caret = $(this).find('span.fa')
    if $caret.hasClass('fa-caret-down')
      $caret.removeClass('fa-caret-down').addClass('fa-caret-up')
      $(this).removeClass('closed')
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $(this).addClass('closed')
