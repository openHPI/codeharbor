# frozen_string_literal: true

class Collection < ApplicationRecord
  validates :title, presence: true

  has_many :collection_users, dependent: :destroy
  has_many :users, through: :collection_users

  has_many :collection_exercises, dependent: :destroy
  has_many :exercises, through: :collection_exercises

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
