class UserMailer < ApplicationMailer

  def registration_confirmation(user)
    @user = user
    mail(to: user.email, subject: "Registration Confirmation")
  end

  def reset_password(user)
    @user = user
    mail(to: user.email, subject: "Reset Password")
  end
end