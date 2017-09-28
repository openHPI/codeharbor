class AddFileExtensionToFileTypes < ActiveRecord::Migration
  def change
    add_column :file_types, :file_extension, :string
  end
end
