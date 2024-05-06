# frozen_string_literal: true

module ProformaService
  class ExportTasks < ServiceBase
    def initialize(tasks:)
      super()
      @tasks = tasks
    end

    def execute
      Zip::OutputStream.write_buffer do |zio|
        @tasks.each do |task|
          zip_file = ExportTask.call(task:)
          zio.put_next_entry("task_#{task.id}-#{task.title.underscore.gsub(/[^0-9A-Za-z.-]/, '_')}.zip")
          zio.write zip_file.string
        end
      end
    end
  end
end
