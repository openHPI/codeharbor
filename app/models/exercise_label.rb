# frozen_string_literal: true

class ExerciseLabel < ApplicationRecord
  belongs_to :exercise
  belongs_to :label
end
