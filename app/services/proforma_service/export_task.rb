# frozen_string_literal: true

module ProformaService
  class ExportTask < ServiceBase
    def initialize(exercise: nil, options: {})
      @exercise = exercise
      @options = options
    end

    def execute
      @task = ConvertExerciseToTask.call(exercise: @exercise, options: @options)
      exporter = Proforma::Exporter.new(@task)
      exporter.perform
    end
  end
end
