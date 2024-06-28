# frozen_string_literal: true

class NbpPushJob < ApplicationJob
  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 5

  def perform(task)
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| LomService::ExportLom.call(task:, xml:) }

    Nbp::PushConnector.instance.push_lom!(builder.to_xml)

    Rails.logger.debug { "Task ##{task.id} \"#{task}\" pushed to NBP" }
  end
end
