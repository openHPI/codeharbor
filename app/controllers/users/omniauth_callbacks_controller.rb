# frozen_string_literal: true

require 'omni_auth/nonce_store'

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :require_user!
    skip_after_action :verify_authorized
    # SAML doesn't support the CSRF protection
    protect_from_forgery except: %i[mocksaml bird nbp]

    def sso_callback
      session[:omniauth_provider] = omniauth_provider
      # `current_user` refers to an existing user signed in before starting the SAML workflow.
      # Thus, this value is only present when adding a new identity to an authenticated account.
      if current_user.present?
        add_idp_to_existing_user
      elsif user_identity.persisted?
        sign_in_with_identity
      else
        register_new_user
      end
    end

    alias bird sso_callback
    alias nbp sso_callback
    alias mocksaml sso_callback

    def deauthorize # rubocop:disable Metrics/AbcSize
      # In case of the `nbp` provider, we remove the SAML identity only and not the `enmeshed` identity.
      # The relationship is still established and currently non-removable by enmeshed.
      identity = current_user.identities.find_by(omniauth_provider:)

      if identity.nil?
        # i18n-tasks-use t('users.omniauth_callbacks.failure_deauthorize_not_linked')
        set_flash(:alert, '.failure_deauthorize_not_linked')

      elsif current_user.omniauth_identities.one? && !current_user.password_set?
        # i18n-tasks-use t('users.omniauth_callbacks.failure_deauthorize_last_identity')
        set_flash(:alert, '.failure_deauthorize_last_identity')

      elsif identity.destroy
        remove_provider_from_session(omniauth_provider)
        # i18n-tasks-use t('users.omniauth_callbacks.success_deauthorize')
        set_flash(:notice, '.success_deauthorize')

      elsif identity.errors.any?
        # i18n-tasks-use t('users.omniauth_callbacks.failure_deauthorize')
        set_flash(:alert, '.failure_deauthorize', reason: identity.errors.full_messages.join(', '))
      end
      redirect_to edit_user_registration_path, status: :see_other
    end

    private

    def add_idp_to_existing_user # rubocop:disable Metrics/AbcSize
      store_location_for(:user, edit_user_registration_path)

      if user_identity.persisted?
        # i18n-tasks-use t('users.omniauth_callbacks.idp_linked_to_other_account')
        set_flash(:alert, '.idp_linked_to_other_account')
        sign_in_and_redirect current_user, event: :authentication and return
      end

      current_user.identities << user_identity
      if current_user.valid?
        set_flash(:notice, 'devise.omniauth_callbacks.success')
      else
        set_flash(:error, 'devise.omniauth_callbacks.failure', reason: current_user.errors.full_messages.join(', '))
      end
      sign_in_and_redirect current_user, event: :authentication
    end

    def sign_in_with_identity
      user = user_identity.user

      # Update some profile information on every login if present
      update_user_attributes(user)
      if user.errors.any?
        # i18n-tasks-use t('users.omniauth_callbacks.failure_update')
        set_flash(:alert, '.failure_update', reason: user.errors.full_messages.join(', '))
      else
        set_flash(:notice, 'devise.omniauth_callbacks.success')
      end

      sign_in_and_redirect user
    end

    def register_new_user # rubocop:disable Metrics/AbcSize
      if omniauth_provider == 'nbp'
        # go through NBP wallet connection process to create new account
        redirect_to nbp_wallet_connect_users_path, status: :see_other
      else
        user = User.new_from_omniauth(omniauth_user_info, omniauth_provider, provider_uid)
        user.skip_confirmation!

        if user.save
          set_flash(:notice, 'devise.omniauth_callbacks.success')
          sign_in_and_redirect user, event: :authentication
        else
          set_flash(:alert, 'devise.omniauth_callbacks.failure', reason: user.errors.full_messages.join(', '))
          redirect_to new_user_registration_url, status: :see_other
        end
      end
    end

    def update_user_attributes(user)
      user.assign_attributes(omniauth_user_info.slice(:email, :first_name, :last_name).to_h.compact)
      if user.changed?
        # We don't want to send a confirmation email for any of the changes
        user.skip_confirmation_notification!
        user.skip_reconfirmation!
        user.save
      end
    end

    def remove_provider_from_session(provider)
      # Prevent any further interaction with the given provider, as the user has deauthorized it.
      # This is necessary to avoid the user being redirected to the IdP after signing out.
      # In short: Once deauthorized, SLO is not enabled any longer for the provider..
      return unless session[:omniauth_provider] == provider

      session.delete(:saml_uid)
      session.delete(:saml_session_index)
      session.delete(:omniauth_provider)
    end

    # We use the configured OmniAuth camelization to include the user-facing name of the provider in the flash message
    def set_flash(type, key, kind: OmniAuth::Utils.camelize(omniauth_provider), reason: '')
      flash[type] = t(key, kind:, reason:) if is_flashing_format?
    end

    def current_user
      # Check if an existing user is already signed in and trying to add a new identity to their account;
      # the session ID is passed through the RelayState then (see the `AbstractSaml` strategy).
      #
      # If the RelayState contains the ID of the current user, we pass it on, so that the middleware can find the
      # current user. This is necessary to avoid creating a new user.
      @current_user ||= User.find_by(id: OmniAuth::NonceStore.pop(params[:RelayState])) || super
    end

    def user_identity
      @user_identity ||= UserIdentity.includes(:user).find_or_initialize_by(omniauth_provider:, provider_uid:)
    end

    def omniauth_provider
      request.env['omniauth.auth']&.provider || params[:provider]
    end

    def provider_uid
      request.env['omniauth.auth'].uid
    end

    def omniauth_user_info
      request.env['omniauth.auth'].info
    end
  end
end
