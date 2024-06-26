# frozen_string_literal: true

class AddParentIds < ActiveRecord::Migration[7.0]
  def change
    add_column :model_solutions, :parent_id, :integer, null: true, limit: 1
    add_column :tests, :parent_id, :integer, null: true, limit: 1
    add_column :task_files, :parent_id, :integer, null: true, limit: 1
  end
end
