# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    skip_before_action :require_user!
    skip_after_action :verify_authorized
    # GET /resource/password/new
    # def new
    #   super
    # end

    # POST /resource/password
    # def create
    #   super
    # end

    # GET /resource/password/edit?reset_password_token=abcdef
    # def edit
    #   super
    # end

    # PUT /resource/password
    def update
      super do |resource|
        # When the user was updated successfully, a custom password was set.
        # The `resource.errors.empty?` is also used by Devise internally.
        resource.update(password_set: true) if resource.errors.empty?
      end
    end

    # protected

    # def after_resetting_password_path_for(resource)
    #   super(resource)
    # end

    # The path used after sending reset password instructions
    # def after_sending_reset_password_instructions_path_for(resource_name)
    #   super(resource_name)
    # end
  end
end
