show_ajax_message = (msg, type) ->
  cls = 'alert-success' if type == 'notice'
  cls = 'alert-danger' if type == 'alert'
  $("#flash-message").html "<div id='flash-#{type}' class='alert #{cls}'>#{msg}</div>"
  $("#flash-#{type}").delay(6000).slideUp 'medium'

$(document).ajaxComplete (event, request) ->
  msg = decodeURI(request.getResponseHeader("X-Message"))
  type = request.getResponseHeader("X-Message-Type")
  show_ajax_message msg, type unless type == 'empty' #use whatever popup, notification or whatever plugin you want

ready =->
  $('#flash-message').children().first().delay(5000).slideUp 'medium'

$(document).on('turbolinks:load', ready)
