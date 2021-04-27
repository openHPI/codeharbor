# frozen_string_literal: true

module ProformaService
  class ExportTask < ServiceBase
    def initialize(task: nil, options: {})
      @task = task
      @options = options
    end

    def execute
      @proforma_task = ConvertTaskToProformaTask.call(task: @task, options: @options)
      exporter = Proforma::Exporter.new(task: @proforma_task)
      exporter.perform
    end
  end
end
