class RemoveExerciseIdFromLabels < ActiveRecord::Migration
  def change
    remove_column :labels, :exercise_id, :integer
  end
end
