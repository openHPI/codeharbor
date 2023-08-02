# frozen_string_literal: true

class AddProformaTestConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :tests, :configuration, :jsonb
  end
end
