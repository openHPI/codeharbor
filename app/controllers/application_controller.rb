class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery unless Rails.env.test? with: :exception

  #http://www.rubydoc.info/docs/rails/AbstractController/Helpers/ClassMethods:helper_method
  helper_method :current_user

  def current_user
    if session[:user_id]
      return User.find(session[:user_id])
    else
      return nil
    end
  end
end
