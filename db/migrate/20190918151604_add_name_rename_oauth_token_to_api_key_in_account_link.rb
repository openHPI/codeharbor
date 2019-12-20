class AddNameRenameOauthTokenToApiKeyInAccountLink < ActiveRecord::Migration[5.2]
  def change
    add_column :account_links, :name, :string
    rename_column :account_links, :oauth2_token, :api_key
  end
end
