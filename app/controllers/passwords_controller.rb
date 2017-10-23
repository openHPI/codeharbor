class PasswordsController < ApplicationController
  def forgot
    email = params[:email].to_s

    if params[:email].blank?
      redirect_to forgot_password_home_index_path, alert: "Email not present." and return
    end

    user = User.find_by(email: email.downcase)
    respond_to do |format|
      if user.present? && user.email_confirmed
        user.generate_password_token!
        UserMailer.reset_password(user).deliver_now
        format.html { redirect_to login_path, notice: "Email to reset password has been sent." }
      else
        format.html { redirect_to forgot_password_home_index_path, alert: "Email address not found. Please check and try again."}
      end
    end
  end

  def reset
    token = params[:token].to_s

    if token.blank?
      redirect_to login_path, alert: 'Token not present'
    end

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password], params[:password_confirmation])
        redirect_to login_path, notice: "Your password was successfully changed"
      else
        redirect_to reset_password_home_index_path(confirm_token: token), alert: user.errors.full_messages.first
      end
    else
      redirect_to login_path, alert: 'Link not valid or expired. Try generating a new link.'
    end
  end
end
