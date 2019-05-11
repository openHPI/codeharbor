# frozen_string_literal: true

module ProformaService
  class Import < ServiceBase
    def initialize(zip: nil, user: nil)
      @zip = zip
      @user = user
    end

    def execute
      importer = Proforma::Importer.new(@zip)
      @task = importer.perform
      initialize_exercise
    end

    private

    def initialize_exercise
      @exercise = Exercise.new(
        title: @task.title,
        descriptions: [Description.new(text: @task.description, language: @task.language)],
        instruction: @task.internal_description,
        execution_environment: execution_environment,
        tests: tests,
        uuid: @task.uuid,
        exercise_files: task_files.values,
        user: @user
      )
      # set_parent_relation
    end

    def task_files
      @task_files ||= @task.files.reject { |key| key == 'ms-placeholder-file' }.transform_values do |task_file|
        if !task_file.binary
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
            attachment: file_base64(task_file),
            attachment_file_name: task_file.filename,
            attachment_content_type: task_file.mimetype
          )
        end
      end
    end

    def file_base64(file)
      "data:#{file.mimetype || 'image/jpeg'};base64,#{Base64.encode64(file.content)}"
    end

    def tests
      @task.tests.map do |test_object|
        Test.new(
          feedback_message: test_object.meta_data['feedback-message'],
          testing_framework: TestingFramework.where(
            name: test_object.meta_data['testing-framework'],
            version: test_object.meta_data['testing-framework-version']
          ).first_or_initialize,
          exercise_file: test_file(test_object)
        )
      end
    end

    def test_file(test_object)
      task_files[test_object.files.first.id].tap { |file| file.purpose = 'test' }
    end

    def execution_environment
      ExecutionEnvironment.where(language: @task.proglang[:name], version: @task.proglang[:version]).first_or_initialize
    end

    def set_meta_data
      exercise.title = @task.title
    end
  end
end
