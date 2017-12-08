class Collection < ActiveRecord::Base
  validates :title, presence: true

  has_and_belongs_to_many :users
  has_and_belongs_to_many :exercises, dependent: :destroy

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