class HomeController < ApplicationController
  def index
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
end
