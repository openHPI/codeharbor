# frozen_string_literal: true

class Message < ApplicationRecord
  validates :text, presence: true

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id', inverse_of: :sent_messages
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id', inverse_of: :received_messages
end
