# frozen_string_literal: true

class AddTimestampsToCollectionTasks < ActiveRecord::Migration[7.1]
  def change
    add_timestamps(:collection_tasks, default: -> { 'CURRENT_TIMESTAMP' })
  end
end
