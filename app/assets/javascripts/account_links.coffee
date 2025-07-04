ready = ->
  $('.generate-api-key-token').on 'click', ->
    $('#account_link_api_key').val(generateRandomHex32())

  $('.remove-account-link-form').on 'ajax:success', (e, data) ->
    $row_value = $(e.currentTarget).parents('.row-value')
    $(e.currentTarget).parents('.table-list').remove()
    if $row_value.children().length == 0
      $row_value.parents('.row').remove()


$(document).on('turbo-migration:load', ready)
