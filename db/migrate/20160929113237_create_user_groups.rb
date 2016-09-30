class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.boolean :is_admin, default: false
      t.references :user, index: true
      t.references :group, index: true

      t.timestamps null: false
    end
    add_foreign_key :user_groups, :users
    add_foreign_key :user_groups, :groups
  end
end