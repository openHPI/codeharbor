class Collection < ActiveRecord::Base
  validates :title, presence: true

  belongs_to :user
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
    self.exercises.delete.all
  end
end