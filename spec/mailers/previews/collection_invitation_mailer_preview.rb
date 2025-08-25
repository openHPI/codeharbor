# frozen_string_literal: true

require 'factory_bot_rails'

class CollectionInvitationMailerPreview < ActionMailer::Preview
  def send_invitation
    collection = FactoryBot.build(:collection, id: 1)
    user = FactoryBot.build(:user, id: 2)
    CollectionInvitationMailer.with(collection:, recipient: user).send_invitation
  end
end
