# frozen_string_literal: true

class AddFileExtensionToProgrammingLanguage < ActiveRecord::Migration[7.1]
  def change
    add_column :programming_languages, :file_extension, :string
  end
end
