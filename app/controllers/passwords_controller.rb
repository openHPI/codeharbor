# frozen_string_literal: true

class PasswordsController < ApplicationController
  def forgot
    email = params[:email].to_s

    redirect_to(forgot_password_home_index_path, alert: t('controllers.password.email_not_present')) && return if params[:email].blank?

    user = User.find_by(email: email.downcase)
    respond_to do |format|
      if user.present? && user.email_confirmed
        user.generate_password_token!
        UserMailer.reset_password(user).deliver_now
        format.html { redirect_to login_path, notice: t('controllers.password.email_sent') }
      else
        format.html { redirect_to forgot_password_home_index_path, alert: t('controllers.password.email_not_found') }
      end
    end
  end

  def reset
    token = params[:token].to_s

    redirect_to login_path, alert: t('controllers.password.token_not_present') if token.blank?

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password], params[:password_confirmation])
        redirect_to login_path, notice: t('controllers.password.change_successful')
      else
        redirect_to reset_password_home_index_path(confirm_token: token), alert: user.errors.full_messages.first
      end
    else
      redirect_to login_path, alert: t('controllers.password.link_invalid')
    end
  end
end
