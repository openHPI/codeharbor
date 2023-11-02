# frozen_string_literal: true

class TaskContribution < ApplicationRecord
  belongs_to :modifying_task, class_name: 'Task', inverse_of: :task_contribution, foreign_key: :task_id

  enum status: {pending: 0, closed: 1, merged: 2}

  def close
    self.status = :closed
    save
  end

  def base_task
    modifying_task.parent
  end
end
