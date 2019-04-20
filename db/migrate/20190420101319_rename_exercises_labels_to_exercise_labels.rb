class RenameExercisesLabelsToExerciseLabels < ActiveRecord::Migration[5.2]
  def change
    rename_table 'exercises_labels', 'exercise_labels'
  end
end
