class AddIdToAccountLinkUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :account_link_users, :id, :primary_key
  end
end
