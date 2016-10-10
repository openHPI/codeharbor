class UpdateForeignKeyUserGroupsGroups < ActiveRecord::Migration
  def change
    # remove the old foreign_key
    remove_foreign_key :user_groups, :groups

    # add the new foreign_key
    add_foreign_key :user_groups, :groups, on_delete: :cascade
  end
end