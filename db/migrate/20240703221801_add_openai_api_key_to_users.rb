# frozen_string_literal: true

class AddOpenaiApiKeyToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :openai_api_key, :string
  end
end
