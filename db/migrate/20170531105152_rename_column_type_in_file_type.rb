class RenameColumnTypeInFileType < ActiveRecord::Migration
  def change
    rename_column :file_types, :type, :name
  end
end
