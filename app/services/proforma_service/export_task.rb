# frozen_string_literal: true

module ProformaService
  class ExportTask < ServiceBase
    def initialize(task: nil, options: {})
      super()
      @task = task
      @options = options
    end

    def execute
      @proforma_task = ConvertTaskToProformaTask.call(task: @task, options: @options)
      namespaces = [{prefix: 'CodeOcean', uri: 'codeocean.openhpi.de'}]
      exporter = Proforma::Exporter.new(task: @proforma_task, custom_namespaces: namespaces)
      exporter.perform
    end
  end
end
