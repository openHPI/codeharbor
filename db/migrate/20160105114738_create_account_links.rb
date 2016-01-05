class CreateAccountLinks < ActiveRecord::Migration
  def change
    create_table :account_links do |t|

      t.timestamps null: false
    end
  end
end
