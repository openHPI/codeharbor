# frozen_string_literal: true

module Authentication
  def sign_in(user, password)
    page.driver.post(user_session_path, user: {email: user.email, password:})
  end

  def sign_in_with_js_driver(user, password)
    visit(new_user_session_path)
    fill_in(I18n.t('sessions.email.label'), with: user.email)
    fill_in(I18n.t('sessions.password.label'), with: password)
    click_button(I18n.t('sessions.login'))
    expect(page).to have_content(I18n.t('devise.sessions.signed_in'))
  end
end
