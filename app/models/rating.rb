# frozen_string_literal: true

class Rating < ApplicationRecord
  SUBCATEGORIES = %i[originality description_quality test_quality model_solution_quality].freeze
  CATEGORIES = SUBCATEGORIES + %i[overall_rating]

  CATEGORIES.each do |category|
    validates category, numericality: {only_integer: true, less_than_or_equal_to: 5, greater_than: 0}
  end

  belongs_to :task
  belongs_to :user
end
