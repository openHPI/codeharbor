class AddMetaDataToTaskAndTest < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :meta_data, :jsonb, default: {}
    add_column :tests, :meta_data, :jsonb, default: {}
  end
end
