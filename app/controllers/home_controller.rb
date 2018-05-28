class HomeController < ApplicationController
  def index
    @index = true
  end

  def about
    render 'about'
  end

  def account_link_documentation
    render 'account_link_documentation'
  end

  def confirm_email
    user = User.find_by(confirm_token: params[:confirm_token])
    if user
      user.email_activate
      redirect_to login_url, notice: t('controllers.home.email_confirmed')
    else
      redirect_to home_index_path, notice: t('controllers.home.no_user')
    end
  end

  def forgot_password
    render 'forgot_password'
  end

  def reset_password
    @token = params[:confirm_token]
    render 'reset_password'
  end

  def resend_confirmation
    render 'resend_confirmation'
  end

  def send_confirmation
    email = params[:email]
    if email.blank?
      redirect_to resend_confirmation_home_index_path, alert: t('controllers.home.no_email') and return
    end

    user = User.find_by(email: email.downcase)

    respond_to do |format|
      if user
        UserMailer.registration_confirmation(user).deliver_now
        format.html { redirect_to home_index_path, notice: t('controllers.home.send_confirmation.success')}
      else
        format.html { redirect_to resend_confirmation_home_index_path, alert: t('controllers.home.send_confirmation.alert')}
      end
    end
  end
end
