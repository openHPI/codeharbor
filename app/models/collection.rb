# frozen_string_literal: true

class Collection < ApplicationRecord
  validates :title, presence: true
  validates :users, presence: true

  has_many :collection_users, dependent: :destroy
  has_many :users, through: :collection_users

  has_many :collection_tasks, dependent: :destroy
  has_many :tasks, through: :collection_tasks

  # def add_exercise(exercise)
  #   exercises << exercise unless exercises.find_by(id: exercise.id)
  # end
  #
  def remove_task(task)
    tasks.delete(task)
  end

  def remove_all
    tasks.each do |task|
      tasks.delete(task)
    end
  end
end
