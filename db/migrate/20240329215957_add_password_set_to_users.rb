# frozen_string_literal: true

class AddPasswordSetToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_set, :boolean, default: true, null: false
  end
end
