class AddPurposeToExerciseFile < ActiveRecord::Migration
  def change
    add_column :exercise_files, :purpose, :string
  end
end
