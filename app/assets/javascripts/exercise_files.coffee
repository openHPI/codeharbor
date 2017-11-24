# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

loadFileScript =->

  $('.remove-attachment').on 'click', (event) ->
    event.preventDefault()
    $(this).parent().hide()
    $(this).parent().next().show()

  $('.toggle-input').on 'click', (event) ->
    event.preventDefault()

    content = $(this).next()
    first = content.children()[0]
    second = content.children()[1]

    if ($(second).attr('data-display') == 'false')
      $(this).text($(this).data('text-toggled'))
      $(first).attr('data-display', "false").hide()
      $(second).attr('data-display', "true").show()
    else
      $(this).text($(this).data('text-initial'))
      $(second).attr('data-display', "false").hide()
      $(first).attr('data-display', "true").show()

ready =->
    $(document).on "fields_added.nested_form_fields", (event, param) ->
      loadFileScript()

    loadFileScript()

$(document).ready(ready)
$(document).on('page:load', ready)