# frozen_string_literal: true

class AccessRequest < ApplicationMailer
  def send_access_request(user, admin, group)
    @user = user
    @admin = admin
    @group = group
    mail(to: @admin.email, subject: "#{user.name} wants to access your Group '#{group.name}'")
  end

  def send_contribution_request(author, exercise, user)
    @author = author
    @exercise = exercise
    @user = user
    mail(to: @author.email, subject: "#{user.name} wants to contribute to your Exercise '#{exercise.title}'")
  end
end
