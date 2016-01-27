class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  has_secure_password

  has_many :account_links
  has_many :exercises
end
