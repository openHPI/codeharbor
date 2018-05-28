class UpdateAccountLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :account_links, :client_id, :string
    add_column :account_links, :client_secret, :string
  end
end
