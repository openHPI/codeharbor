class AddPushUrlToAccountLinks < ActiveRecord::Migration
  def change
    add_column :account_links, :push_url, :string
  end
end
