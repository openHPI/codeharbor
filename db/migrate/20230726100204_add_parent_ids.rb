# frozen_string_literal: true

class AddParentIds < ActiveRecord::Migration[7.0]
  def change
    add_reference :model_solutions, :parent, foreign_key: {on_delete: :nullify, to_table: :model_solutions}, index: true
    add_reference :tests, :parent, foreign_key: {on_delete: :nullify, to_table: :tests}, index: true
    add_reference :task_files, :parent, foreign_key: {on_delete: :nullify, to_table: :task_files}, index: true
  end
end
