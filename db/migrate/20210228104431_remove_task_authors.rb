class RemoveTaskAuthors < ActiveRecord::Migration[6.0]
  def change
    drop_table :task_authors
  end
end
