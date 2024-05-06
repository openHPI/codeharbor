# frozen_string_literal: true

class AddTestingFrameworkToTests < ActiveRecord::Migration[7.0]
  def change
    add_reference :tests, :testing_framework, foreign_key: true
  end
end
