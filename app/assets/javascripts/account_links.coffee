# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready =->
  $('.generate-client-id').on 'click', ->
    $('.client-id').val(generateUUID())
  $('.generate-client-secret').on 'click', ->
    $('.client-secret').val(generateRandomHex32())
  $('.generate-oauth2-token').on 'click', ->
    $('.oauth2-token').val(generateRandomHex32())
$(document).on('turbolinks:load', ready)