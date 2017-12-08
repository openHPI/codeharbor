class CollectionRemoveColumnUser < ActiveRecord::Migration
  def change
    remove_column :collections, :user_id, index: true, foreign_key: true
  end
end
