# frozen_string_literal: true

class TaskContribution < ApplicationRecord
  belongs_to :suggestion, class_name: 'Task', inverse_of: :task_contribution, foreign_key: :task_id
  delegate :user, :user=, :access_level=, to: :suggestion
  accepts_nested_attributes_for :suggestion

  # TODO: Test this scope (maybe already done with the test written for task.rb#l45).
  scope :for_task_uuid, ->(uuid) { joins(:suggestion).where(suggestion: {parent_uuid: uuid}) }

  # TODO: Use `_prefix: true`
  enum status: {pending: 0, closed: 1, merged: 2}, _default: :pending

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

  def base
    suggestion.parent
  end

  def base=(task)
    suggestion.parent = task
  end

  def to_s
    I18n.t('task_contributions.model.contribution_title', task_title: base.title)
  end
end
