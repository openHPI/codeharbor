# frozen_string_literal: true
class ChangeColumnTypesToText < ActiveRecord::Migration[7.1]
  def up
    change_column :messages, :text, :text
    change_column :model_solutions, :description, :text
    change_column :model_solutions, :internal_description, :text
    change_column :tasks, :description, :text
    change_column :tasks, :internal_description, :text
    change_column :tests, :description, :text
    change_column :tests, :internal_description, :text
  end

  def down
    change_column :messages, :text, :string
    change_column :model_solutions, :description, :string
    change_column :model_solutions, :internal_description, :string
    change_column :tasks, :description, :string
    change_column :tasks, :internal_description, :string
    change_column :tests, :description, :string
    change_column :tests, :internal_description, :string
  end
end
