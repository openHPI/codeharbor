class AccountLink < ApplicationRecord
  validates :push_url, presence: true
  validates :account_name, presence: true
  validates :oauth2_token, presence: true
  validates :client_id, presence: true
  validates :client_secret, presence: true

  belongs_to :user
  has_and_belongs_to_many :external_users, class_name: 'User'

  def readable
    self.account_name + " / " + self.push_url;
  end

end
