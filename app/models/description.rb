# frozen_string_literal: true

class Description < ApplicationRecord
  belongs_to :exercise

  LANGUAGES = %w[en de fr es ja cn].freeze
  LANGUAGES.freeze
end
