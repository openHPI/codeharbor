class UpdateReferenceFileTypesExerciseFiles < ActiveRecord::Migration
  def change
    remove_reference :exercise_files, :file_types, index: true

    add_reference :exercise_files, :file_type, index: true, foreign_key: true
  end
end
