class CreateImportFileCaches < ActiveRecord::Migration[5.2]
  def change
    create_table :import_file_caches do |t|
      t.belongs_to :user
      t.jsonb :data
      t.attachment :zip_file
      t.timestamps
    end
  end
end
