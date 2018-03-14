class Cart < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :exercises, dependent: :destroy
  validates :user, presence: true

  def self.find_cart_of(user)
    cart = find_by(user: user)
    if cart
      cart
    else
      create(user: user)
    end
  end
  def add_exercise(exercise)
    unless self.exercises.find_by(id: exercise.id)
      self.exercises << exercise
    end
  end

  def remove_exercise(exercise)
    self.exercises.delete(exercise)
  end

  def remove_all
    self.exercises.each do |exercise|
      self.exercises.delete(exercise)
    end
  end
end
