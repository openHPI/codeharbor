module AuthenticationHelpers
  def login(user)
    post login_path, params: {:email => user.email, :password => user.password}
    follow_redirect!
  end
end