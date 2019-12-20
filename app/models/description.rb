# frozen_string_literal: true

class Description < ApplicationRecord
  belongs_to :exercise

  validates :text, presence: true

  LANGUAGES = %w[en de fr es ja cn].freeze
  LANGUAGES.freeze
end
