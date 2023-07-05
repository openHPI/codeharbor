# frozen_string_literal: true

class TaskContribution < ApplicationRecord
  belongs_to :task

  enum status: {pending: 0, closed: 1, merged: 2}
end
