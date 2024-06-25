# frozen_string_literal: true

class NbpSyncJob < ApplicationJob
  retry_on Faraday::Error, Nbp::PushConnector::ServerError, wait: :polynomially_longer, attempts: 5

  def perform(uuid)
    task = Task.find_by(uuid:)

    if task.present? && task.access_level_public?
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| LomService::ExportLom.call(task:, xml:) }
      Nbp::PushConnector.instance.push_lom!(builder.to_xml)
      Rails.logger.debug { "Task ##{task.id} \"#{task}\" pushed to NBP" }
    else
      Nbp::PushConnector.instance.delete_task!(uuid)
      Rails.logger.debug { "Task with UUID #{uuid} deleted from NBP" }
    end
  end
end
