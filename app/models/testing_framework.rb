# frozen_string_literal: true

class TestingFramework < ApplicationRecord
  has_many :tests, dependent: :restrict_with_error
end
