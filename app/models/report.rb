# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :exercise
  belongs_to :user
end
