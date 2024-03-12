# frozen_string_literal: true

class MigrateTaskDescriptionsFixKramdownQuotes < ActiveRecord::Migration[7.1]
  def up
    Task.find_each do |task|
      task.description = fix_kramdown_descriptions(task.description)
      task.save!(touch: false)
    end
  end

  def fix_kramdown_descriptions(string)
    # removes double escapes of symbols and unnecessary newlines
    Kramdown::Document.new(string, line_width: -1).to_kramdown.gsub(/\\([\\*_`\[\]\{"'|])/, '\1').strip
  end
end

class Task < ApplicationRecord
end
