class AddUsernameAndDescriptionToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :username, :string
    add_column :users, :description, :text
  end
end
