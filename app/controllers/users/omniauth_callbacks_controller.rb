# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :require_user!
    skip_after_action :verify_authorized
    # SAML doesn't support the CSRF protection
    protect_from_forgery except: %i[samltestid bird nbp]

    def sso_callback # rubocop:disable Metrics/AbcSize
      # The instance variable `@user` is used by Devise internally and should be set here
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        # The `sign_in_and_redirect` will only proceed with the login if the account has been confirmed
        # either through trust by the IdP or with a confirmation mail. Until then, a flash message
        # notifies users about the missing email confirmation
        sign_in_and_redirect @user, event: :authentication
        # We use the configured OmniAuth camilization to include the user-facing name of the provider in the flash message
        set_flash_message(:notice, :success, kind: OmniAuth::Utils.camelize(provider)) if is_navigational_format?
        session['omniauth_provider'] = provider
      else
        if is_navigational_format? && @user.errors.any?
          # We show validation errors to the user, for example because required data from the IdP was missing
          set_flash_message(:alert, :failure, kind: OmniAuth::Utils.camelize(provider),
            reason: @user.errors.full_messages.join(', '))
        end
        # Removing extra as it can overflow some session stores
        session["devise.#{provider}_data"] = request.env['omniauth.auth'].except('extra')
        redirect_to new_user_registration_url
      end
    end

    alias bird sso_callback
    alias nbp sso_callback
    alias samltestid sso_callback

    def provider
      request.env['omniauth.auth'].provider
    end

    # More info at:
    # https://github.com/heartcombo/devise#omniauth

    # GET|POST /resource/auth/twitter
    # def passthru
    #   super
    # end

    # GET|POST /users/auth/twitter/callback
    # def failure
    #   super
    # end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end
  end
end
