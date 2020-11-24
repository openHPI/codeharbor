# frozen_string_literal: true

class TaskFile < ApplicationRecord
  belongs_to :fileable, polymorphic: true

  def full_file_name
    "#{path.present? ? "#{path}/" : ''}#{name}"
  end
end
