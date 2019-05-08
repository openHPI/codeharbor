# frozen_string_literal: true

module ProformaService
  class Import < ServiceBase
    def initialize(zip: nil)
      @zip = zip
    end

    def execute
      importer = Proforma::Importer.new(@zip)
      @task = importer.perform
      @task
    end

    private

    def create_exercise
      @exercise = Exercise.new(
        title: @task.title,
        descriptions: [Description.new(text: Task.description, language: @task.language)],
        instruction: @task.internal_description,
        execution_environment: execution_environment,
        # tests: tests,
        uuid: @task.uuid,
        files: files.values
      )
      # set_parent_relation
      exercise.save
    end

    def files
      @files ||= @task.files.transform_values do |task_file|
        if task_file.binary
          ExerciseFile.new(
            content: task_file.content,
            full_file_name: task_file.filename,
            read_only: task_file.usage_by_lms.in?(%w[display download]),
            hidden: task_file.visible == 'no',
            role: task_file.internal_description
          )
        else
          ExerciseFile.new(
            full_file_name: task_file.filename,
            read_only: task_file.usage_by_lms.in?(%w[display download]),
            hidden: task_file.visible == 'no',
            role: task_file.internal_description,
            attachment: task_file.content
          )
        end
      end
    end

    def execution_environment
      ExecutionEnvironment.where(language: @task.proglang[:name], version: @task.proglang[:version]).first_or_initialize
    end

    def set_meta_data
      exercise.title = @task.title
    end
  end
end
