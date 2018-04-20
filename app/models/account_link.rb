class AccountLink < ApplicationRecord
  validates :push_url, presence: true
  validates :account_name, presence: true
  validates :oauth2_token, presence: true

  belongs_to :user
  has_and_belongs_to_many :users

  def readable
    self.push_url + " / " + self.account_name;
  end

end
