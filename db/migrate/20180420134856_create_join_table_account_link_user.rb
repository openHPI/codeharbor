class CreateJoinTableAccountLinkUser < ActiveRecord::Migration[5.0]
  def change
    create_table :account_links_users do |t|
      t.integer :account_link_id
      t.integer :user_id
      t.index [:account_link_id, :user_id]
    end
  end
end
