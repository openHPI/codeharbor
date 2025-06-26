show_ajax_message = (msg, type) ->
  cls = 'alert-success' if type == 'notice'
  cls = 'alert-danger' if type == 'alert'
  $("#flash-message").html "<div id='flash-#{type}' class='alert flash #{cls} my-2 alert-dismissible fade show'><p class='mb-0' id='flash-notice'>#{decodeURIComponent(msg)}</p><button aria-label='Close' class='btn-close' data-bs-dismiss='alert' type='button'></button></div>"
  $("#flash-#{type}").delay(6000).slideUp 'medium'

$(document).ajaxComplete (event, request) ->
  msg = decodeURIComponent(request.getResponseHeader("X-Message"))
  type = request.getResponseHeader("X-Message-Type")
  show_ajax_message msg, type unless msg == "null" || type == 'empty' #use whatever popup, notification or whatever plugin you want

ready = ->
  $('#flash-message').children().first().delay(5000).slideUp 'medium'

$(document).on('turbo-migration:load', ready)
