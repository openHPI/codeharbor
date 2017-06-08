class UpdateToExerciseFiles < ActiveRecord::Migration
  def change
    remove_column :exercise_files, :main, :boolean
    remove_column :exercise_files, :file_extension, :string
    add_reference :exercise_files, :file_types, index: true
    add_column :exercise_files, :role, :string
    add_column :exercise_files, :hidden, :boolean
    add_column :exercise_files, :read_only, :boolean
  end
end
