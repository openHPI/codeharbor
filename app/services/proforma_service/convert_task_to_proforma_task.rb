# frozen_string_literal: true

module ProformaService
  class ConvertTaskToProformaTask < ServiceBase
    def initialize(task:, options: {})
      @task = task
      @options = options
    end

    def execute
      create_task
    end

    private

    def create_task
      Proforma::Task.new(
        {
          title: @task.title,
          description: description,
          internal_description: @task.internal_description,
          proglang: proglang,
          files: @task.files.map { |file| task_file file },
          tests: tests,
          uuid: @task.uuid,
          parent_uuid: @task.parent_uuid,
          language: @task.language,
          model_solutions: model_solutions
        }.compact
      )
    end

    def description
      return @task.description if @options[:description_format] == 'md'

      Kramdown::Document.new(@task.description).to_html.strip
    end

    def proglang
      {name: @task.programming_language&.language, version: @task.programming_language&.version}
    end

    def model_solutions
      @task.model_solutions.map do |model_solution|
        Proforma::ModelSolution.new(
          id: "ms-#{model_solution.id}",
          description: model_solution.description,
          internal_description: model_solution.internal_description,
          xml_id: model_solution.xml_id,
          files: model_solution.files.map do |file|
            task_file(file)
          end
          #   [
          #   Proforma::TaskFile.new(
          #     id: model_solution.id,
          #     content: model_solution.content,
          #     filename: model_solution.full_file_name,
          #     used_by_grader: false,
          #     usage_by_lms: 'display',
          #     visible: model_solution.hidden ? 'no' : 'yes',
          #     binary: false,
          #     internal_description: model_solution.role
          #   )
          # ]
        )
      end
    end

    def tests
      @task.tests.map do |test|
        file = test.files.first
        Proforma::Test.new(
          id: test.xml_id,
          title: test.title,
          description: test.description,
          internal_description: test.internal_description,
          test_type: test.test_type,
          files: test.files.map { |file| task_file file },
          configuration: test_configuration(test, file),
          meta_data: test_meta_data(test)
        )
      end
    end

    def test_configuration(test, file)
      {
        'entry-point' => file.full_file_name,
        'framework' => test.testing_framework&.name,
        'version' => test.testing_framework&.version
      }
    end

    def test_meta_data(test)
      {
        'feedback-message' => test.feedback_message,
        'testing-framework' => test.testing_framework&.name,
        'testing-framework-version' => test.testing_framework&.version
      }.compact
    end

    # def test_file(file)
    #   Proforma::TaskFile.new(
    #     id: file.id,
    #     content: file.content,
    #     filename: file.full_file_name,
    #     used_by_grader: true,
    #     visible: file.hidden ? 'no' : 'yes',
    #     binary: false,
    #     internal_description: file.role || 'teacher_defined_test'
    #   )
    # end

    # def files
    #   @task.files
    #            .filter { |file| file.role != 'reference_implementation' && !file.in?(@task.tests.map(&:exercise_file)) }.map do |file|
    #     task_file(file)
    #   end
    # end

    def task_file(file)
      task_file = Proforma::TaskFile.new(
        id: file.id,
        filename: file.full_file_name,
        used_by_grader: file.used_by_grader,
        visible: file.visible,
        usage_by_lms: file.usage_by_lms,
        internal_description: file.internal_description
      )
      add_content_to_task_file(file, task_file)
      task_file
    end

    def add_content_to_task_file(file, task_file)
      if file.attachment.attached?
        task_file.content = attachment_content(file)
        task_file.binary = true
        task_file.mimetype = file.attachment.content_type
      else
        task_file.content = file.content
        task_file.binary = false
      end
    end

    def attachment_content(file)
      file.attachment.blob.download
    end
  end
end
