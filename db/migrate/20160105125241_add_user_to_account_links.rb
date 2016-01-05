class AddUserToAccountLinks < ActiveRecord::Migration
  def change
    add_reference :account_links, :user, index: true, foreign_key: true
  end
end
