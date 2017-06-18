class RemoveFileNameExerciseFiles < ActiveRecord::Migration
  def change
    remove_column :exercise_files, :file_name, :string
  end
end
