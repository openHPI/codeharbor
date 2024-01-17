# frozen_string_literal: true

class AddRankToCollectionTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :collection_tasks, :rank, :integer, default: 0, null: false
  end
end
