class AddIdToExerciseLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :exercise_labels, :id, :primary_key
  end
end
