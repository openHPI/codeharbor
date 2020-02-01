# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      authenticate_user user
    else
      redirect_to login_url, alert: t('controllers.session.invalid_credentials')
    end
  end

  def email_link
    if current_user.to_param == params[:user]
      redirect_to user_messages_path(current_user)
    else
      session[:user_id] = nil
      flash[:notice] = t('controllers.session.login_first')
      @messages_redirect = true
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to home_index_path, notice: t('controllers.session.logged_out')
  end

  private

  def authenticate_user(user)
    if user.email_confirmed
      session[:user_id] = user.id
      if params[:redirect]
        redirect_to user_messages_path(current_user)
      else
        redirect_to home_index_path
      end
    else
      redirect_to login_url, alert: t('controllers.session.activate_email')
    end
  end
end
