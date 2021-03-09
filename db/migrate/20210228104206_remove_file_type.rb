class RemoveFileType < ActiveRecord::Migration[6.0]
  def change
    drop_table :file_types
  end
end
