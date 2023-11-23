# frozen_string_literal: true

class TaskFilePolicy < ApplicationPolicy
  def task_file
    @record
  end

  def corresponding_task
    fileable = task_file.fileable
    fileable.is_a?(Task) ? fileable : fileable.task
  end

  def download_attachment?
    corresponding_task.showable_by?(@user)
  end

  def extract_text_data?
    corresponding_task.updateable_by?(@user)
  end
end
