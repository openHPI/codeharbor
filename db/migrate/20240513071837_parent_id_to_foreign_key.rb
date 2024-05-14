# frozen_string_literal: true

class ParentIdToForeignKey < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :model_solutions, :model_solutions, column: :parent_id, on_delete: :nullify
    add_foreign_key :tests, :tests, column: :parent_id, on_delete: :nullify
    add_foreign_key :task_files, :task_files, column: :parent_id, on_delete: :nullify
  end
end
