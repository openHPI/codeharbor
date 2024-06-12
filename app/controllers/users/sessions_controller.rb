# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    skip_before_action :require_user!
    skip_after_action :verify_authorized
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    def destroy
      # In order to redirect the user to the IdP in case of a SAML single-log-out request, we need to keep
      # some SAML information in the session. They are used by the `after_sign_out_path_for` below
      # and will be removed once the logout completed as part of the `idp_slo_session_destroy` hook
      # in the AbstractSAML strategy (`lib/omni_auth/strategies/abstract_saml.rb`).
      #
      # Preserve the saml_uid, saml_session_index and omniauth_provider in the session
      # This is done by copying those and setting these after destroying the session (through `super`)
      saml_uid = session[:saml_uid]
      saml_session_index = session[:saml_session_index]
      omniauth_provider = session[:omniauth_provider]
      super do
        session[:saml_uid] = saml_uid
        session[:saml_session_index] = saml_session_index
        session[:omniauth_provider] = omniauth_provider
      end
    end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end

    def after_sign_out_path_for(_)
      provider = session[:omniauth_provider]
      if session[:saml_uid] && session[:saml_session_index] && provider
        provider_config = Devise.omniauth_configs[provider.to_sym]
        return super unless provider_config

        strategy_class = provider_config.strategy_class
        return spslo_path_for(provider) if strategy_class.default_options.idp_slo_service_url
      end

      # If SLO is not supported, we first delete all information from the current session
      # This is mainly done to remove the SAML information we stored before
      session.clear
      # Then, we delegate the call to the parent
      super
    end

    def spslo_path_for(provider)
      # spslo stands for "Service-Provider initiated Single-Log-Out"
      # We only need to construct the provider-specific path and return it

      # First, we generate the method name of the routes helper for this provder
      authorize_path_helper = "user_#{provider}_omniauth_authorize_path"
      # Then, we call the method to get the path `/users/auth/<provider>`
      authorize_path = public_send(authorize_path_helper)
      # Finally, the predefined `/spslo` suffix is appended
      # This path is defined and handled by the `omniauth-saml` gem
      "#{authorize_path}/spslo"
    end
  end
end
