# frozen_string_literal: true

require 'factory_bot_rails'

class AccessRequestMailerPreview < ActionMailer::Preview
  def send_access_request
    group = FactoryBot.build(:group, id: 1)
    admin = group.group_memberships.find(&:role_admin?).user
    user = FactoryBot.build(:user)
    AccessRequestMailer.with(user:, admin:, group:).send_access_request
  end
end
