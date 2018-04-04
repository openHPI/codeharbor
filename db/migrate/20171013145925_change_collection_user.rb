class ChangeCollectionUser < ActiveRecord::Migration
  def change
    remove_column :collections_users, :exercise_id, :int, index: true
    add_column :collections_users, :user_id, :int, index: true
  end
end
