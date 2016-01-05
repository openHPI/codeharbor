class AddAccountNameToAccountLink < ActiveRecord::Migration
  def change
    add_column :account_links, :account_name, :string
  end
end
