# frozen_string_literal: true

class License < ApplicationRecord
  has_many :tasks, dependent: :restrict_with_error

  validates :name, presence: true

  def to_s
    link.present? ? "#{name}: #{link}" : name
  end
end
