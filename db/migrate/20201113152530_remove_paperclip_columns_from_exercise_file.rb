class RemovePaperclipColumnsFromExerciseFile < ActiveRecord::Migration[6.0]
  def change
    remove_column :exercise_files, :attachment_file_name, :string
    remove_column :exercise_files, :attachment_content_type, :string
    remove_column :exercise_files, :attachment_file_size, :bigint
    remove_column :exercise_files, :attachment_updated_at, :datetime
  end
end
