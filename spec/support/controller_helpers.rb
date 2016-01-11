module ControllerHelpers
  def login_with(user = double('user'))
  	session[:user_id] = user.id
  	redirect_to exercises_path
  end
end
