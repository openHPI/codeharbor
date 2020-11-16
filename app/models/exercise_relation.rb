# frozen_string_literal: true

class ExerciseRelation < ApplicationRecord
  validates :relation, presence: true

  belongs_to :origin, class_name: 'Exercise', inverse_of: :origin_relations
  belongs_to :clone, class_name: 'Exercise', inverse_of: :clone_relations
  belongs_to :relation
end
