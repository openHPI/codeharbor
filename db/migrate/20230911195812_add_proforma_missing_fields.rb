class AddProformaMissingFields < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :submission_restrictions, :jsonb
    add_column :tasks, :external_resources, :jsonb
    add_column :tasks, :grading_hints, :jsonb
  end
end
