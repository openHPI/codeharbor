# frozen_string_literal: true

class ProgrammingLanguage < ApplicationRecord
  def language_with_version
    "#{language} #{version}"
  end
end
