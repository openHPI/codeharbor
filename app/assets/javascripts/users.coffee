# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready =->
  $('.remove-avatar').on 'click', (event) ->
    event.preventDefault()
    $(this).parent().hide()
    $('.hidden-avatar-present').val(false)
    $('.file-input').show()

  $('.show-description').on 'click', (event) ->
    event.preventDefault()
    $('.account-link-description').toggle()

$(document).on('turbolinks:load', ready)