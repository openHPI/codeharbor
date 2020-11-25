# frozen_string_literal: true

class Message < ApplicationRecord
  validates :text, presence: true

  belongs_to :sender, class_name: 'User', inverse_of: :sent_messages
  belongs_to :recipient, class_name: 'User', inverse_of: :received_messages

  scope :received_by, ->(user) { where(recipient: user).where.not(recipient_status: 'd') }
  scope :sent_by, ->(user) { where(sender: user).where.not(sender_status: 'd') }

  after_save :destroy_deleted_message

  def mark_as_deleted(user)
    self.sender_status = 'd' if sender == user
    self.recipient_status = 'd' if recipient == user
  end

  private

  def destroy_deleted_message
    destroy if deleted_by_both?
  end

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
