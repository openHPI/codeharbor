# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :task
  belongs_to :user
end
