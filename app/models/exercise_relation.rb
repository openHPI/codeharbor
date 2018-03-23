class ExerciseRelation < ApplicationRecord
  validates :relation, presence: true

  belongs_to :origin, :class_name => 'Exercise', :foreign_key => 'origin_id'
  belongs_to :clone, :class_name => 'Exercise', :foreign_key => 'clone_id'
  belongs_to :relation, :foreign_key => 'relation_id'

end
