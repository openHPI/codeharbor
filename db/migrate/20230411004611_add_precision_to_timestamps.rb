# frozen_string_literal: true

class AddPrecisionToTimestamps < ActiveRecord::Migration[7.0]
  def up
    tables = %w[
      account_links
      collections
      comments
      groups
      import_file_caches
      labels
      licenses
      messages
      ratings
      reports
      testing_frameworks
      tests
      users
    ]

    tables.each do |table|
      change_column table, :created_at, :datetime, precision: 6
      change_column table, :updated_at, :datetime, precision: 6
    end

    change_column :active_storage_attachments, :created_at, :datetime, precision: 6
    change_column :active_storage_blobs, :created_at, :datetime, precision: 6
    change_column :taggings, :created_at, :datetime, precision: 6
    change_column :users, :reset_password_sent_at, :datetime, precision: 6
    change_column :users, :remember_created_at, :datetime, precision: 6
    change_column :users, :confirmed_at, :datetime, precision: 6
    change_column :users, :confirmation_sent_at, :datetime, precision: 6
    change_column :users, :locked_at, :datetime, precision: 6
  end
end
