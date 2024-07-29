# frozen_string_literal: true

module ProformaService
  class ExportTask < ServiceBase
    def initialize(task: nil, options: {})
      super()
      @task = task
      @options = options
    end

    def execute
      task = ConvertTaskToProformaTask.call(task: @task, options: @options)
      ProformaXML::Exporter.call(task:, version: @options[:version])
    end
  end
end
