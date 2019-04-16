# frozen_string_literal: true

class Collection < ApplicationRecord
  validates :title, presence: true

  has_and_belongs_to_many :users
  has_and_belongs_to_many :exercises, dependent: :destroy

  def add_exercise(exercise)
    exercises << exercise unless exercises.find_by(id: exercise.id)
  end

  def remove_exercise(exercise)
    exercises.delete(exercise)
  end

  def remove_all
    exercises.each do |exercise|
      exercises.delete(exercise)
    end
  end
end
