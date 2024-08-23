# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    skip_before_action :require_user!
    skip_after_action :verify_authorized
    before_action :configure_sign_up_params, only: [:create] # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    def update
      avatar_present = params.require(:user).delete(:avatar_present)
      super do |resource|
        resource.avatar.purge if params[:user][:avatar].nil? && avatar_present == 'false'
        if resource.password_set_changed?
          # If a user tried to set a password but failed, we need to reset the password_set flag.
          # Further, we need to remove the current_password error, since the user didn't enter their current password.
          resource.errors.delete(:current_password)
          resource.restore_password_set!
        end
      end
    end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name avatar])
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name avatar openai_api_key])
    end

    def after_update_path_for(resource)
      user_path(resource)
    end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
    def set_password_for_omniauth(resource, params)
      if !resource.password_set? && params[:password].present?
        # If an OmniAuth user tries to set a password, we need to take two extra steps:
        # 1. Set the password_set flag to true, since a custom password is being set.
        # 2. Set the encrypted_password and current_password to a dummy value, since the user doesn't have a real password.
        #    This is needed by Devise to update the password and validate the "current" password.
        params[:current_password] = Devise.friendly_token
        resource.assign_attributes(
          password_set: true,
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          encrypted_password: Devise::Encryptor.digest(resource.class, params[:current_password])
        )
      end
    end

    def update_resource(resource, params)
      set_password_for_omniauth(resource, params)

      # Only require current password if the user configured one. Otherwise (i.e., for OmniAuth users), don't require it.
      if resource.password_set?
        resource.update_with_password(params)
      else
        resource.update_without_password(params)
      end
    end
  end
end
