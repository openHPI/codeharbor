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
    Pundit.policy(@user, corresponding_task).show?
  end

  def extract_text_data?
    download_attachment?
    # This was originally only permitted for users who can edit the file because it is only used in the update frontend.
    # Since it does not update something itself it can be allowed for users that can view/download a task.
  end
end
