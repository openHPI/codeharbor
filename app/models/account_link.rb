# frozen_string_literal: true

class AccountLink < ApplicationRecord
  validates :check_uuid_url, presence: true
  validates :push_url, presence: true
  validates :api_key, presence: true

  belongs_to :user

  has_many :account_link_users, dependent: :destroy
  has_many :external_users, through: :account_link_users

  def readable
    push_url
  end
end
