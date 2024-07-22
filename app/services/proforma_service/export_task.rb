# frozen_string_literal: true

module ProformaService
  class ExportTask < ServiceBase
    def initialize(task: nil, options: {})
      super()
      @task = task
      @options = options
    end

    def execute
      ProformaXML::Exporter.call(task: ConvertTaskToProformaTask.call(task: @task, options: @options))
    end
  end
end
