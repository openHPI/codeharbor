class RemovePaperclipColumnsFromImportFileCache < ActiveRecord::Migration[6.0]
  def change
    remove_column :import_file_caches, :zip_file_file_name, :string
    remove_column :import_file_caches, :zip_file_content_type, :string
    remove_column :import_file_caches, :zip_file_file_size, :bigint
    remove_column :import_file_caches, :zip_file_updated_at, :datetime
  end
end
