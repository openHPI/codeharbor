class RenameCollectionsUsersToCollectionUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table 'collections_users', 'collection_users'
  end
end
