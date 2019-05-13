# frozen_string_literal: true

module ProformaService
  class ExportTasks < ServiceBase
    def initialize(exercises: nil)
      @exercises = exercises
    end

    def execute
      Zip::OutputStream.write_buffer do |zio|
        @exercises.each do |exercise|
          zip_file = ExportTask.call(exercise: exercise)
          zio.put_next_entry("task_#{exercise.id}.zip")
          zio.write zip_file.string
        end
      end
    end
  end
end
