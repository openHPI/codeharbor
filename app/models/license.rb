# frozen_string_literal: true

class License < ApplicationRecord
  has_many :tasks, dependent: :nullify
end
