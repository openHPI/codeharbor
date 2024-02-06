# frozen_string_literal: true

class AddRankAndTimestampToCollectionTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :collection_tasks, :rank, :integer, default: 0, null: false
    add_timestamps(:collection_tasks, default: -> { 'CURRENT_TIMESTAMP' })
  end
end
