class RenameExerciseLabelToTaskLabel < ActiveRecord::Migration[6.0]
  def change
    remove_belongs_to :exercise_labels, :exercise
    add_belongs_to :exercise_labels, :task, foreign_key: true

    rename_table :exercise_labels, :task_labels

  end
end
