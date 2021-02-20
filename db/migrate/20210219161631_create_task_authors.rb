class CreateTaskAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :task_authors, id: :serial, force: :cascade do |t|
      t.references 'task', foreign_key: true
      t.references 'user'

      t.timestamps
    end

  end
end
