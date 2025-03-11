# frozen_string_literal: true

module Authentication
  def sign_in(user, password)
    page.driver.post(user_session_path, user: {email: user.email, password:})
  end

  def sign_in_with_js_driver(user, password)
    visit(new_user_session_path)
    fill_in(:user_email, with: user.email)
    fill_in(:user_password, with: password)
    click_button(I18n.t('common.button.log_in'))
    expect(page).to have_content(I18n.t('devise.sessions.signed_in'))
  end
end

RSpec.configure do |config|
  config.include Authentication, type: :system
end
