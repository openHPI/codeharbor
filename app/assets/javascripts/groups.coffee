ready =->
#  $(".change-hidden-field").click ->
#    value = (this).id
#    document.getElementById('option').value = value
#    $(".index").submit()
#
#  if option = document.getElementById('option')
#    $(document.getElementById(option.value)).addClass('selected')

  $(document).on 'ajax:success', '.share-account-link-form', (e, data) ->
    $(e.currentTarget.parentElement).html(data["button"])

$(document).on('turbolinks:load', ready)
