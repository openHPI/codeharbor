# frozen_string_literal: true

class Relation < ApplicationRecord
  validates :name, presence: true
end
