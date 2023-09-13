# frozen_string_literal: true

module ProformaService
  class ExportTask < ServiceBase
    def initialize(task: nil, options: {})
      super()
      @task = task
      @options = options
    end

    def execute
      converter_result = ConvertTaskToProformaTask.call(task: @task, options: @options)
      exporter = ProformaXML::Exporter.new(task: converter_result[:task], custom_namespaces: converter_result[:namespaces])
      exporter.perform
    end
  end
end
