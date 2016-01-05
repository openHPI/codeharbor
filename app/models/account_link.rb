class AccountLink < ActiveRecord::Base
  validates :push_url, presence: true
  validates :account_name, presence: true
end
