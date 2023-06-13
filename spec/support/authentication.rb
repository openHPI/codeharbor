# frozen_string_literal: true

module Authentication
  def sign_in(user, password)
    page.driver.post(user_session_path, user: {email: user.email, password:})
  end
end
