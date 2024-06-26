# frozen_string_literal: true

class FixParentIdFormat < ActiveRecord::Migration[7.1]
  def change
    up_only do
      change_column :task_files, :parent_id, :bigint, limit: nil
      change_column :model_solutions, :parent_id, :bigint, limit: nil
      change_column :tests, :parent_id, :bigint, limit: nil
    end
  end
end
