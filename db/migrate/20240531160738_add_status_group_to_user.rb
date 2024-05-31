# frozen_string_literal: true

class AddStatusGroupToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :status_group, :integer, null: false, limit: 1, default: 0, comment: 'Used as enum in Rails'
  end
end
