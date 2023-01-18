# frozen_string_literal: true

class GroupTask < ApplicationRecord
  belongs_to :group
  belongs_to :task

  validates :task, uniqueness: {scope: :group}
end
