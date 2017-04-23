class AccessRequest < ApplicationMailer

  def send_access_request(user, admin, group)
    @user = user
    @admin = admin
    @group = group
    mail(to: @admin.email, subject: "#{user.name} wants to access your Group '#{group.name}'")
  end
end
