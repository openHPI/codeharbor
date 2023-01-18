class AddGroupsTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :group_tasks, id: :serial, force: :cascade do |t|
      t.belongs_to :task, foreign_key: true, null: false, index: true
      t.belongs_to :group, foreign_key: true, null: false, index: true
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
