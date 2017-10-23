class AddDefaultFalseToEmailConfirmed < ActiveRecord::Migration
  def change
    change_column :users, :email_confirmed, :boolean, :default => false
  end
end
