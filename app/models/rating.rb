# frozen_string_literal: true

class Rating < ApplicationRecord
  SUBCATEGORIES = %i[originality description_quality test_quality model_solution_quality].freeze
  CATEGORIES = SUBCATEGORIES + %i[overall_rating]

  validates :overall_rating, numericality: {only_integer: true, less_than_or_equal_to: 5, greater_than: 0}
  validates :originality, numericality: {only_integer: true, less_than_or_equal_to: 5, greater_than: 0}
  validates :description_quality, numericality: {only_integer: true, less_than_or_equal_to: 5, greater_than: 0}
  validates :test_quality, numericality: {only_integer: true, less_than_or_equal_to: 5, greater_than: 0}
  validates :model_solution_quality, numericality: {only_integer: true, less_than_or_equal_to: 5, greater_than: 0}

  belongs_to :task
  belongs_to :user

  def to_h
    (%i[task_id user_id] + Rating::CATEGORIES).index_with {|sym| send(sym) }
  end
end
