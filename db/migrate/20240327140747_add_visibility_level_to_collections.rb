# frozen_string_literal: true

class AddVisibilityLevelToCollections < ActiveRecord::Migration[7.1]
  def change
    add_column :collections, :visibility_level, :integer, null: false, limit: 2, default: 0, comment: 'Used as enum in Rails'
  end
end
