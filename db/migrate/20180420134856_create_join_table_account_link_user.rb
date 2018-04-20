class CreateJoinTableAccountLinkUser < ActiveRecord::Migration[5.0]
  def change
    create_join_table :account_links, :users do |t|
      t.index [:account_link_id, :user_id]
    end
  end
end
