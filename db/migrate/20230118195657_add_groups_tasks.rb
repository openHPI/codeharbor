# frozen_string_literal: true

class AddGroupsTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :group_tasks, id: :uuid, force: :cascade do |t|
      t.belongs_to :task, foreign_key: true, null: false, index: true
      t.belongs_to :group, foreign_key: true, null: false, index: true
      t.timestamps
    end
  end
end
