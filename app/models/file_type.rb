# frozen_string_literal: true

class FileType < ApplicationRecord
  belongs_to :exercise_files

  def name_with_extension
    "#{name} (#{file_extension})"
  end
end
