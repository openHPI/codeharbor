# frozen_string_literal: true

class CollectionExercise < ApplicationRecord
  belongs_to :collection
  belongs_to :exercise
end
