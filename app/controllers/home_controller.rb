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
      redirect_to login_url, notice: "Welcome to the Sample App! Your email has been confirmed. Please sign in to continue."
    else
      redirect_to home_index_path, notice: "Sorry. User does not exist"
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
      return render json: {error: 'Email not present'}
    end

    user = User.find_by(email: email.downcase)

    respond_to do |format|
      if user
        UserMailer.registration_confirmation(user).deliver_now
        format.html { redirect_to home_index_path, notice: "Confirmation Email was resent."}
      else
        format.hmtl { redirect_to home_index_path, notice: "Could not find a user for the given email address."}
      end
    end
  end
end
