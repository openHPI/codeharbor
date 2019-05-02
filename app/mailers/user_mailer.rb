# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def registration_confirmation(user)
    @user = user
    mail(to: user.email, subject: t('user_mailer.registration_confirmation.header'))
  end

  def reset_password(user)
    @user = user
    mail(to: user.email, subject: t('user_mailer.reset_password.header'))
  end
end
