# frozen_string_literal: true

class AddPublicToCollections < ActiveRecord::Migration[7.1]
  def change
    add_column :collections, :visibility_level, :integer, null: false, limit: 1, default: 0, comment: 'Used as enum in Rails'
  end
end
