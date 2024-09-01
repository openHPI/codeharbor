# frozen_string_literal: true

class TaskContribution < ApplicationRecord
  # The `suggestion` contains the updated version of the task.
  belongs_to :suggestion, class_name: 'Task', inverse_of: :task_contribution, foreign_key: :task_id
  # The `base` denotes the original version of the task that should be updated.
  has_one :base, through: :suggestion, source: :parent, required: true

  delegate :user, :user=, :access_level=, to: :suggestion

  accepts_nested_attributes_for :suggestion

  scope :for_task_uuid, ->(uuid) { joins(:suggestion).where(suggestion: {parent_uuid: uuid}) }

  enum :status, {pending: 0, closed: 1, merged: 2}, default: :pending, prefix: true

  def self.new_for(task, user)
    suggestion = task.clean_duplicate(user, change_title: false)
    new(suggestion:, base: task)
  end

  def close
    update(status: :closed)
  end

  def decouple
    duplicate = suggestion.duplicate(set_parent_identifiers: false)
    TaskContribution.transaction do
      raise ActiveRecord::Rollback unless duplicate.save && close

      duplicate
    end
  end

  def self.parent_resource
    Task
  end

  def to_s
    I18n.t('task_contributions.model.contribution_title', task_title: base.title)
  end
end
