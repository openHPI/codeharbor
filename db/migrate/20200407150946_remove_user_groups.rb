class RemoveUserGroups < ActiveRecord::Migration[6.0]
  def change
    drop_table :user_groups
  end
end
