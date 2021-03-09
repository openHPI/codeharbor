class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks, id: :serial, force: :cascade do |t|
      t.string "title"
      t.string "description"
      t.string "internal_description"
      t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
      t.uuid "parent_uuid"
      t.string 'language'

      t.references 'programming_language'
      t.references 'user'

      t.timestamps
    end
  end
end
