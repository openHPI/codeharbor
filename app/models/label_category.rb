# frozen_string_literal: true

class LabelCategory < ApplicationRecord
  has_many :labels
end
