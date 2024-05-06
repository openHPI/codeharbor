# frozen_string_literal: true

class TestingFramework < ApplicationRecord
  has_many :tests, dependent: :restrict_with_error

  def name_with_version
    "#{name} #{version}"
  end
end
