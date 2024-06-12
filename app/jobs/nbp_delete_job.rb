# frozen_string_literal: true

class NbpDeleteJob < ApplicationJob
  def perform(task_uuid)
    Nbp::PushConnector.instance.delete_task!(task_uuid)

    Rails.logger.debug { "Task ##{task_uuid} deleted from NBP" }
  end
end
