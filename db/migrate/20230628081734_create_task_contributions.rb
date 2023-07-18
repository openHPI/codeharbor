# frozen_string_literal: true

class CreateTaskContributions < ActiveRecord::Migration[7.0]
  def change
    create_table :task_contributions, id: :serial, force: :cascade do |t|
      t.belongs_to :task, foreign_key: true, null: false, index: true
      t.integer :status, null: false, default: 0, limit: 1, comment: 'Used as enum in Rails'
      t.timestamps
    end
  end
end
