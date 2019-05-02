# frozen_string_literal: true

class ExerciseGroupAccess < ApplicationRecord
  belongs_to :exercise
  belongs_to :group
end
