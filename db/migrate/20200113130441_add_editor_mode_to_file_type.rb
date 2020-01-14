class AddEditorModeToFileType < ActiveRecord::Migration[5.2]
  def change
    add_column :file_types, :editor_mode, :string
  end
end
