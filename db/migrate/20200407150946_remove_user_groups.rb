class RemoveUserGroups < ActiveRecord::Migration[6.0]
  def change
    drop_table :user_groups do |t|
      t.boolean "is_admin", default: false
      t.boolean "is_active", default: false
      t.integer "user_id"
      t.integer "group_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["group_id"], name: "index_user_groups_on_group_id"
      t.index ["user_id"], name: "index_user_groups_on_user_id"
    end
  end
end
