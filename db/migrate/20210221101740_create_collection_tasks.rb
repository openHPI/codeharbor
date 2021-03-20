class CreateCollectionTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :collection_tasks do |t|
      t.belongs_to :task, index: true, foreign_key: true
      t.belongs_to :collection, index: true, foreign_key: true
    end
  end
end
