class AddFileNameToExerciseFile < ActiveRecord::Migration
  def change
    add_column :exercise_files, :file_name, :string
  end
end
