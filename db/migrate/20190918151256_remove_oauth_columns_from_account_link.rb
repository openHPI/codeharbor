class RemoveOauthColumnsFromAccountLink < ActiveRecord::Migration[5.2]
  def change
    remove_column :account_links, :account_name
    remove_column :account_links, :client_id
    remove_column :account_links, :client_secret
  end
end
