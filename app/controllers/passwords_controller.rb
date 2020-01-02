# frozen_string_literal: true

class PasswordsController < ApplicationController
  before_action :set_email_if_present, only: :forgot
  before_action :set_token_if_present, only: :reset

  def forgot
    user = User.find_by(email: @email.downcase)
    respond_to do |format|
      if user.present? && user.email_confirmed
        sent_forgot_password_mail(user)
        format.html { redirect_to login_path, notice: t('controllers.password.email_sent') }
      else
        format.html { redirect_to forgot_password_home_index_path, alert: t('controllers.password.email_not_found') }
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def reset
    user = User.find_by(reset_password_token: @token)
    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password], params[:password_confirmation])
        redirect_to login_path, notice: t('controllers.password.change_successful')
      else
        redirect_to reset_password_home_index_path(confirm_token: @token), alert: user.errors.full_messages.first
      end
    else
      redirect_to login_path, alert: t('controllers.password.link_invalid')
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def set_token_if_present
    @token = params[:token].to_s
    return redirect_to login_path, alert: t('controllers.password.token_not_present') if @token.blank?
  end

  def sent_forgot_password_mail(user)
    user.generate_password_token!
    UserMailer.reset_password(user).deliver_now
  end

  def set_email_if_present
    @email = params[:email].to_s
    return redirect_to(forgot_password_home_index_path, alert: t('controllers.password.email_not_present')) if @email.blank?
  end
end
