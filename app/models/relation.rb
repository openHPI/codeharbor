# frozen_string_literal: true

class Relation < ApplicationRecord
  validates :name, presence: true
  # has_many :exercise_relations, dependent: :restrict_with_error
end
