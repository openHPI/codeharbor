ready = ->
  $('.remove-avatar').on 'click', (event) ->
    event.preventDefault()
    $(this).parent().hide()
    $('.hidden-avatar-present').val(false)
    $('.file-input').show()

  $('.show-description').on 'click', (event) ->
    event.preventDefault()
    $('.account-link-description').toggle()

  $('.delete-user').on 'click', (event) ->
    event.preventDefault()
    new bootstrap.Modal('#notification-modal').show();


$(document).on('turbo-migration:load', ready)
