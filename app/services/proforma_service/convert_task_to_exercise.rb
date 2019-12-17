# frozen_string_literal: true

module ProformaService
  class ConvertTaskToExercise < ServiceBase
    def initialize(task:, user:, exercise:)
      @task = task
      @user = user
      @exercise = exercise || Exercise.new
    end

    def execute
      import_exercise
      @exercise
    end

    private

    def import_exercise
      @exercise.assign_attributes(
        user: @user,
        title: @task.title,
        private: @exercise.private.nil? ? true : @exercise.private,
        descriptions: new_descriptions,
        instruction: @task.internal_description,
        execution_environment: execution_environment,
        tests: tests,
        exercise_files: task_files.values,
        state_list: @exercise.persisted? ? 'updated' : 'new',
        deleted: false
      )
    end

    def new_descriptions
      descriptions = @exercise.descriptions.presence || [Description.new(primary: true)]
      primary = descriptions.select(&:primary?).first
      primary.assign_attributes(text: @task.description, language: @task.language)
      descriptions
    end

    def task_files
      @task_files ||= Hash[
        @task.all_files.reject { |file| file.id == 'ms-placeholder-file' }.map do |task_file|
          [task_file.id, exercise_file_from_task_file(task_file)]
        end
      ]
    end

    def exercise_file_from_task_file(task_file)
      ExerciseFile.new({
        full_file_name: task_file.filename,
        read_only: task_file.usage_by_lms.in?(%w[display download]),
        hidden: task_file.visible == 'no',
        role: task_file.internal_description
      }.tap do |params|
        if task_file.binary
          params[:attachment] = file_base64(task_file)
          params[:attachment_file_name] = task_file.filename
          params[:attachment_content_type] = task_file.mimetype
        else
          params[:content] = task_file.content
        end
      end)
    end

    def file_base64(file)
      raise Proforma::MimetypeError, I18n.t('exercises.import_exercise.mimetype_error', filename: file.filename) unless file.mimetype

      "data:#{file.mimetype};base64,#{Base64.encode64(file.content)}"
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
      task_files.delete(test_object.files.first.id).tap { |file| file.purpose = 'test' }
    end

    def execution_environment
      proglang_name = @task.proglang&.dig :name
      proglang_version = @task.proglang&.dig :version
      return @exercise.execution_environment if proglang_name.nil? || proglang_version.nil?

      ExecutionEnvironment.where(language: proglang_name, version: proglang_version).first_or_initialize
    end
  end
end
