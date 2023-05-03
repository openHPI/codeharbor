class AddAccessLevelToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :access_level, :integer, null: false, limit: 1, default: 0, comment: 'Used as enum in Rails'
  end
end
