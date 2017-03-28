module AuthenticationHelpers
  def login(user)
    post_via_redirect login_path, :email => user.email, :password => user.password
  end
end