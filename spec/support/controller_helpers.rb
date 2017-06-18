module ControllerHelpers
  def login_with(user = double('user'))
  	session[:user_id] = user.id
  	redirect_to exercises_path
  end

  def login_user
    @user = FactoryGirl.create(:user)
    login_with(@user)
  end

  def login(user)
    request.session[:user_id] = user.id
  end

  def current_user
    User.find(request.session[:user])
  end
end
