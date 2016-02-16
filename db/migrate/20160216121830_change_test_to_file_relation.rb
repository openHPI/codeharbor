class ChangeTestToFileRelation < ActiveRecord::Migration
  def change
    remove_column :tests, :content, :text
    remove_column :tests, :rating, :integer
    add_reference :tests, :exercise_file, index: true, foreign_key: true
    add_column :exercise_files, :visibility, :boolean
    add_column :exercise_files, :name, :string
    rename_column :exercise_files, :filetype, :file_extension
  end
end
