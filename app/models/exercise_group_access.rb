class ExerciseGroupAccess < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :group
end