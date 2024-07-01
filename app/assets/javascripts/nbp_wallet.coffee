template_validity = 0
finalizing = false

checkStatus = ->
  if !finalizing && window.location.pathname == Routes.nbp_wallet_connect_users_path()
    $.ajax(
      url: Routes.nbp_wallet_relationship_status_users_path()
      success: (data, textStatus, xhr) ->
        if data.status == 'ready' && !finalizing
          finalizing = true
          window.location = Routes.nbp_wallet_finalize_users_path()
    )

countdownValidity = ->
  if template_validity > 0
    template_validity -= 1
    if template_validity == 0
      window.location.reload()

$(document).on 'turbolinks:load', () ->
  # subtracting 5 seconds to make sure the displayed code is always valid (accounting for loading times)
  template_validity = $('.nbp_wallet_qr_code').data('template-validity') - 5

  setInterval checkStatus, 1000
  setInterval countdownValidity, 1000
  $('.regenerate-qr-code-button').on 'click', (event) -> window.location.reload();
