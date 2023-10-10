# frozen_string_literal: true

class AddProformaMissingFields < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :submission_restrictions, :jsonb, default: {}
    add_column :tasks, :external_resources, :jsonb, default: {}
    add_column :tasks, :grading_hints, :jsonb, default: {}
  end
end
