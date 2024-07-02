# frozen_string_literal: true

class AddPersonalApiKeyToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :personal_api_key, :string
  end
end
