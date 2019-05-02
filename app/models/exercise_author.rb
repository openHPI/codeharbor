# frozen_string_literal: true

class ExerciseAuthor < ApplicationRecord
  belongs_to :exercise
  belongs_to :user
end
