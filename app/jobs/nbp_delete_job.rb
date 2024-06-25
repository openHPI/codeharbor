# frozen_string_literal: true

class NbpDeleteJob < ApplicationJob
  retry_on Faraday::Error, wait: :polynomially_longer

  def perform(task_uuid)
    Nbp::PushConnector.instance.delete_task!(task_uuid)

    Rails.logger.debug { "Task with UUID #{task_uuid} deleted from NBP" }
  end
end
