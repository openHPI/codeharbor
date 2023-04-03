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

  $('.delete-user').on 'click', (event) ->
    event.preventDefault()
    $('#notification-modal').modal()

deleteUser = (deletePath) ->
  if confirm(I18n.t('users.show.delete_modal.last_confirm'))
    $.ajax({
      type: 'DELETE',
      url: deletePath,
      success: (response) ->
        if response.status == 'failure'
          alert(response.message)
      error: (_xhr, _textStatus, message) ->
        alert('error: ' + message)
    })

#  post(deletePath, {_method: 'delete', authenticity_token: $('meta[name=csrf-token]').attr('content')})
#    post(deletePath, {_method: 'delete', authenticity_token: $('meta[name=csrf-token]').attr('content')})
  else
    $('#notification-modal').modal('hide')


$(document).on('turbolinks:load', ready)

root = exports ? this;
root.deleteUser = deleteUser
