# frozen_string_literal: true

class GroupTask < ApplicationRecord
  belongs_to :group
  belongs_to :task

  validates :task_id, uniqueness: {scope: :group_id}
end
