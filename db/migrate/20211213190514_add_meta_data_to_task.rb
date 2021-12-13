class AddMetaDataToTask < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :meta_data, :jsonb, default: {}
  end
end
