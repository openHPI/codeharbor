# frozen_string_literal: true

class AccountLink < ApplicationRecord
  validates :push_url, presence: true
  validates :account_name, presence: true
  validates :oauth2_token, presence: true
  validates :client_id, presence: true
  validates :client_secret, presence: true

  belongs_to :user

  has_many :account_link_users, dependent: :destroy
  has_many :external_users, through: :account_link_users

  def readable
    account_name + ' / ' + push_url
  end
end
