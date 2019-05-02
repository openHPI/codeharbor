# frozen_string_literal: true

module ControllerHelpers
  def login_with(user = instance_double('user'))
    session[:user_id] = user.id
    redirect_to exercises_path
  end

  def login_user
    @user = FactoryBot.create(:user)
    login_with(@user)
  end

  def login(user)
    request.session[:user_id] = user.id
  end

  def current_user
    User.find(request.session[:user_id])
  end
end
