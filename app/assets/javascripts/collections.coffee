# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready =->
  $('#share-menu').on 'click', (e) ->
    e.stopPropagation()
    return

$(document).on('turbolinks:load', ready)