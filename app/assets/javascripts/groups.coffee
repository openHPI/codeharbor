ready = ->
  $(document).on 'ajax:success', '.share-account-link-form', (e, data) ->
    $(e.currentTarget.parentElement).html(data["button"])


$(document).on('turbolinks:load', ready)
