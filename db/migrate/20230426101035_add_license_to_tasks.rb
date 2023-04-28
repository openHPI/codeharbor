# frozen_string_literal: true

class AddLicenseToTasks < ActiveRecord::Migration[7.0]
  def change
    add_reference :tasks, :license, foreign_key: true
  end
end
