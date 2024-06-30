# frozen_string_literal: true

class ProgrammingLanguage < ApplicationRecord
  has_many :tasks, dependent: :nullify

  def language_with_version
    "#{language} #{version}"
  end
end
