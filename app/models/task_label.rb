# frozen_string_literal: true

class TaskLabel < ApplicationRecord
  belongs_to :task
  belongs_to :label

  after_destroy :remove_dangling_labels

  def remove_dangling_labels
    label.destroy if label.task_labels.empty?
  end
end
