# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready =->
  $('.generate-api-key-token').on 'click', ->
    $('#account_link_api_key').val(generateRandomHex32())
$(document).on('turbolinks:load', ready)
