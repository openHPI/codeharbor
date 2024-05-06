# frozen_string_literal: true

module ProformaService
  class ExportTask < ServiceBase
    def initialize(task: nil, options: {})
      super()
      @task = task
      @options = options
    end

    def execute
      exporter = ProformaXML::Exporter.new(task: ConvertTaskToProformaTask.call(task: @task, options: @options))
      exporter.perform
    end
  end
end
