# frozen_string_literal: true

class Message < ApplicationRecord
  validates :text, presence: true

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id', inverse_of: :sent_messages
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id', inverse_of: :received_messages

  scope :received_by, ->(user) { where(recipient: user).where('recipient_status != ?', 'd') }
  scope :sent_by, ->(user) { where(sender: user).where('sender_status != ?', 'd') }

  def deleted_by_sender?
    @message.sender_status == 'd'
  end

  def deleted_by_recipient?
    @message.recipient_status == 'd'
  end
end
