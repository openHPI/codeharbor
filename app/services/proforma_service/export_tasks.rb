# frozen_string_literal: true

module ProformaService
  class ExportTasks < ServiceBase
    def initialize(tasks:, options: {})
      super()
      @tasks = tasks
      @options = options
    end

    def execute
      Zip::OutputStream.write_buffer do |zio|
        @tasks.each do |task|
          zip_file = ExportTask.call(task:, options: @options)
          zio.put_next_entry("task_#{task.id}-#{task.title.underscore.gsub(/[^0-9A-Za-z.-]/, '_')}.zip")
          zio.write zip_file.string
        end
      end
    end
  end
end
