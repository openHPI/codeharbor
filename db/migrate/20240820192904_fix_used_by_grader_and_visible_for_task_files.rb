# frozen_string_literal: true

class FixUsedByGraderAndVisibleForTaskFiles < ActiveRecord::Migration[7.1]
  class TaskFile < ApplicationRecord
  end

  disable_ddl_transaction!

  def change
    visibility_options = %w[yes no delayed]
    default_visibility = {'Task' => 'yes', 'Test' => 'no', 'ModelSolution' => 'delayed'}

    TaskFile.where.not(visible: visibility_options).or(TaskFile.where(used_by_grader: nil)).find_each do |task_file|
      task_file.visible = default_visibility[task_file.fileable_type] unless visibility_options.include? task_file.fileable_type
      task_file.used_by_grader = true if task_file.used_by_grader.nil?
      task_file.save!(touch: false)
    end
  end
end
