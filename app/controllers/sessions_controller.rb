class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by(email: params[:email])
    if user and user.authenticate(params[:password])
      if user.email_confirmed
        session[:user_id] = user.id
        if params[:redirect]
          redirect_to user_messages_path(current_user)
        else
          redirect_to home_index_path
        end
      else
        redirect_to login_url, alert: 'Please activate your account by following the instructions in the account confirmation email you received to proceed'
      end
    else
      redirect_to login_url, alert: 'Invalid user/password combination'
    end
  end

  def email_link
    if current_user == params[:user]
      redirect_to user_messages_path(current_user)
    else
      session[:user_id] = nil
      flash[:notice] = "Please login first."
      @messages_redirect = true
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to home_index_path, notice: 'Logged out'
  end
end
