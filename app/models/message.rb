# frozen_string_literal: true

class Message < ApplicationRecord
  validates :text, presence: true

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id', inverse_of: :sent_messages, optional: false
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id', inverse_of: :received_messages, optional: false

  scope :received_by, ->(user) { where(recipient: user).where('recipient_status != ?', 'd') }
  scope :sent_by, ->(user) { where(sender: user).where('sender_status != ?', 'd') }

  def deleted_by_sender?
    sender_status == 'd'
  end

  def deleted_by_recipient?
    recipient_status == 'd'
  end

  def deleted_by_both?
    deleted_by_recipient? && deleted_by_sender?
  end
end
