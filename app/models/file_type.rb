# frozen_string_literal: true

class FileType < ApplicationRecord
  has_many :exercise_files

  def name_with_extension
    "#{name} (#{file_extension})"
  end
end
