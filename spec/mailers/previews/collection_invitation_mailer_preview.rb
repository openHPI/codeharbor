# frozen_string_literal: true

require 'factory_bot_rails'

class CollectionInvitationMailerPreview < ActionMailer::Preview
  def send_invitation
    collection = FactoryBot.build(:collection, id: 1)
    user = FactoryBot.build(:user, id: 2)
    CollectionInvitationMailer.send_invitation(collection, user)
  end
end
