# frozen_string_literal: true

class Rating < ApplicationRecord
  validates :rating, numericality: {only_integer: true, less_than_or_equal_to: 5, greater_than: 0}

  belongs_to :task
  belongs_to :user
end
