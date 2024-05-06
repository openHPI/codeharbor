# frozen_string_literal: true

class AddDescriptionToCollections < ActiveRecord::Migration[7.1]
  def change
    add_column :collections, :description, :string, default: '', null: false
  end
end
