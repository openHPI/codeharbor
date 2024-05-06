# frozen_string_literal: true

require 'omni_auth/nonce_store'

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :require_user!
    skip_after_action :verify_authorized
    # SAML doesn't support the CSRF protection
    protect_from_forgery except: %i[mocksaml bird nbp]

    def sso_callback # rubocop:disable Metrics/AbcSize
      # Check if an existing user is already signed in (passed through the RelayState)
      # and trying to add a new identity to their account. If so, we load the user information
      # and set it as the current user. This is necessary to avoid creating a new user.
      current_user = User.find_by(id: OmniAuth::NonceStore.pop(params[:RelayState]))

      # For existing users, we want to redirect to their profile page after adding a new identity
      store_location_for(:user, edit_user_registration_path) if current_user.present?

      # The instance variable `@user` is used by Devise internally and should be set here
      @user = User.from_omniauth(request.env['omniauth.auth'], current_user)

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
    alias mocksaml sso_callback

    def provider
      request.env['omniauth.auth']&.provider || params[:provider]
    end

    def deauthorize # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      identity = current_user.identities.find_by(omniauth_provider: provider)
      if is_navigational_format? && identity.nil?
        # i18n-tasks-use t('users.omni_auth.failure_deauthorize_not_linked')
        set_flash_message(:alert, :failure_deauthorize_not_linked, kind: OmniAuth::Utils.camelize(provider),
          scope: 'users.omni_auth')
      elsif is_navigational_format? && current_user.identities.count == 1 && !current_user.password_set?
        # i18n-tasks-use t('users.omni_auth.failure_deauthorize_last_identity')
        set_flash_message(:alert, :failure_deauthorize_last_identity, kind: OmniAuth::Utils.camelize(provider),
          scope: 'users.omni_auth')
      elsif is_navigational_format? && identity.destroy
        remove_provider_from_session(provider)
        # i18n-tasks-use t('users.omni_auth.success_deauthorize')
        set_flash_message(:notice, :success_deauthorize, kind: OmniAuth::Utils.camelize(provider),
          scope: 'users.omni_auth')
      elsif is_navigational_format? && identity.errors.any?
        # i18n-tasks-use t('users.omni_auth.failure_deauthorize')
        set_flash_message(:alert, :failure_deauthorize, kind: OmniAuth::Utils.camelize(provider), scope: 'users.omni_auth',
          reason: identity.errors.full_messages.join(', '))
      end
      redirect_to edit_user_registration_path
    end

    private

    def remove_provider_from_session(provider)
      # Prevent any further interaction with the given provider, as the user has deauthorized it.
      # This is necessary to avoid the user being redirected to the IdP after signing out.
      # In short: Once deauthorized, SLO is not enabled any longer for the provider..
      return unless session['omniauth_provider'] == provider

      session.delete('saml_uid')
      session.delete('saml_session_index')
      session.delete('omniauth_provider')
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
