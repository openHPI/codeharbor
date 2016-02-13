class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  has_secure_password

  has_many :account_links
  has_many :exercises
  has_one :cart


  def cart_count
    if cart
      return cart.exercises.size
    else
      return 0
    end
  end

  def name
    "#{first_name} #{last_name}"
  end
end
