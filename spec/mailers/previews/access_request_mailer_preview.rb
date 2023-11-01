# frozen_string_literal: true

require 'factory_bot_rails'

class AccessRequestMailerPreview < ActionMailer::Preview
  def send_access_request
    group = FactoryBot.build(:group, id: 1)
    admin = group.group_memberships.find(&:role_admin?).user
    user = FactoryBot.build(:user)
    AccessRequestMailer.send_access_request(user, admin, group)
  end

  def send_contribution_request
    task = FactoryBot.build(:task)
    author = task.user
    author.id = 1
    user = FactoryBot.build(:user)
    AccessRequestMailer.send_contribution_request(author, task, user)
  end
end
