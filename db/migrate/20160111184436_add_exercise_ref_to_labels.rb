class AddExerciseRefToLabels < ActiveRecord::Migration
  def change
    add_reference :labels, :exercise, index: true, foreign_key: true
  end
end
