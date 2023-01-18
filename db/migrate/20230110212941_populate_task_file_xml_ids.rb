# frozen_string_literal: true

class PopulateTaskFileXmlIds < ActiveRecord::Migration[6.1]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    Task.all.each do |task|
      task.all_files.each_with_index do |file, index|
        file.update_attribute(:xml_id, index)
      end
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
