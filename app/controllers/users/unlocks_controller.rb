# frozen_string_literal: true

module Users
  class UnlocksController < Devise::UnlocksController
    skip_before_action :require_user!
    skip_after_action :verify_authorized
    # GET /resource/unlock/new
    # def new
    #   super
    # end

    # POST /resource/unlock
    # def create
    #   super
    # end

    # GET /resource/unlock?unlock_token=abcdef
    # def show
    #   super
    # end

    # protected

    # The path used after sending unlock password instructions
    # def after_sending_unlock_instructions_path_for(resource)
    #   super(resource)
    # end

    # The path used after unlocking the resource
    # def after_unlock_path_for(resource)
    #   super(resource)
    # end
  end
end
