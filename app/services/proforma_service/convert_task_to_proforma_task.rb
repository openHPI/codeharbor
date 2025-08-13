# frozen_string_literal: true

module ProformaService
  class ConvertTaskToProformaTask < ServiceBase
    def initialize(task:, options: {})
      super()
      @task = task
      @options = options
      @all_files = []
    end

    def execute
      create_task
    end

    private

    def create_task
      ProformaXML::Task.new(
        {
          title: @task.title,
          description:,
          internal_description: @task.internal_description,
          proglang:,
          uuid: @task.uuid,
          parent_uuid: @task.parent_uuid,
          language: @task.language,
          meta_data: @task.meta_data,
          submission_restrictions: @task.submission_restrictions,
          external_resources: @task.external_resources,
          grading_hints: @task.grading_hints,
          files:,
          tests:,
          model_solutions:,
        }.compact
      )
    end

    def description
      return @task.description if @options[:description_format] == 'md'

      string = ApplicationController.helpers.render_markdown(@task.description)
      string.scan(/<\w/).length == 1 ? string.gsub(%r{</?p>}, '') : string
    end

    def proglang
      {name: @task.programming_language&.language, version: @task.programming_language&.version}
    end

    def model_solutions
      @task.model_solutions.map do |model_solution|
        ProformaXML::ModelSolution.new(
          id: model_solution.xml_id,
          description: model_solution.description,
          internal_description: model_solution.internal_description,
          files: model_solution.files.map do |file|
            task_file(file)
          end
        )
      end
    end

    def files
      @task.files.map {|file| task_file file }
    end

    def tests
      @task.tests.map do |test|
        ProformaXML::Test.new(
          id: test.xml_id,
          title: test.title,
          description: test.description,
          internal_description: test.internal_description,
          test_type: test.test_type,
          files: test.files.map {|test_file| task_file test_file },
          configuration: test.configuration,
          meta_data: test.meta_data
        )
      end
    end

    def task_files_equal?(task_file, other)
      task_file.filename == other.filename &&
        task_file.used_by_grader == other.used_by_grader &&
        task_file.visible == other.visible &&
        task_file.usage_by_lms == other.usage_by_lms &&
        task_file.internal_description == other.internal_description &&
        task_content_equal?(task_file, other)
    end

    def task_content_equal?(task_file, other)
      task_file.content == other.content &&
        task_file.binary == other.binary &&
        task_file.mimetype == other.mimetype
    end

    def task_file(file)
      task_file = ProformaXML::TaskFile.new(
        id: file.xml_id,
        filename: file.full_file_name,
        used_by_grader: file.used_by_grader || false,
        visible: file.visible,
        usage_by_lms: file.usage_by_lms,
        internal_description: file.internal_description
      )
      add_content_to_task_file(file, task_file)

      original_file = @all_files.find {|f| task_files_equal?(f, task_file) }
      return original_file if original_file

      @all_files << task_file
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
