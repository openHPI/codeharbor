class AddOAuth2TokenToAccountLinks < ActiveRecord::Migration
  def change
    add_column :account_links, :oauth2_token, :string
  end
end
