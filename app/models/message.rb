# frozen_string_literal: true

class Message < ApplicationRecord
  validates :text, presence: true

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id'
end
