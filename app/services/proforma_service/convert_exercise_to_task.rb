# frozen_string_literal: true

module ProformaService
  class ConvertExerciseToTask < ServiceBase
    def initialize(exercise: nil, options: {})
      @exercise = exercise
      @options = options
    end

    def execute
      create_task
    end

    private

    def create_task
      Proforma::Task.new(
        {
          title: @exercise.title,
          description: description,
          internal_description: @exercise.instruction,
          proglang: proglang,
          files: task_files,
          tests: tests,
          uuid: @exercise.uuid,
          parent_uuid: parent_uuid,
          language: primary_description.language,
          model_solutions: model_solutions
        }.compact
      )
    end

    def description
      return primary_description.text if @options[:description_format] == 'md'

      Kramdown::Document.new(primary_description.text).to_html.strip
    end

    def parent_uuid
      @exercise.clone_relations.first&.origin&.uuid
    end

    def primary_description
      @exercise.descriptions.select(&:primary?).first
    end

    def proglang
      {name: @exercise.execution_environment&.language, version: @exercise.execution_environment&.version}
    end

    def model_solutions
      @exercise.exercise_files.filter { |file| file.role == 'reference_implementation' }.map do |file|
        Proforma::ModelSolution.new(
          id: "ms-#{file.id}",
          files: [
            Proforma::TaskFile.new(
              id: file.id,
              content: file.content,
              filename: file.full_file_name,
              used_by_grader: false,
              usage_by_lms: 'display',
              visible: file.hidden ? 'no' : 'yes',
              binary: false,
              internal_description: file.role
            )
          ]
        )
      end
    end

    def tests
      @exercise.tests.map do |test|
        file = test_file test.exercise_file
        Proforma::Test.new(
          id: test.id,
          title: test.exercise_file.name,
          files: [file],
          configuration: test_configuration(test, file),
          meta_data: test_meta_data(test)
        )
      end
    end

    def test_configuration(test, file)
      {
        'entry-point' => file.filename,
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

    def test_file(file)
      Proforma::TaskFile.new(
        id: file.id,
        content: file.content,
        filename: file.full_file_name,
        used_by_grader: true,
        visible: file.hidden ? 'no' : 'yes',
        binary: false,
        internal_description: file.role || 'teacher_defined_test'
      )
    end

    def task_files
      @exercise.exercise_files
               .filter { |file| file.role != 'reference_implementation' && !file.in?(@exercise.tests.map(&:exercise_file)) }.map do |file|
        task_file(file)
      end
    end

    def task_file(file)
      task_file = Proforma::TaskFile.new(
        id: file.id,
        filename: file.full_file_name,
        usage_by_lms: file.read_only ? 'display' : 'edit',
        visible: file.hidden ? 'no' : 'yes',
        internal_description: file.role || 'regular_file'
      )
      add_content_to_task_file(file, task_file)
      task_file
    end

    def add_content_to_task_file(file, task_file)
      if file.attachment.exists?
        task_file.content = attachment_content(file)
        task_file.used_by_grader = false
        task_file.binary = true
        task_file.mimetype = file.attachment_content_type
      else
        task_file.content = file.content
        task_file.used_by_grader = true
        task_file.binary = false
      end
    end

    def attachment_content(file)
      Paperclip.io_adapters.for(file.attachment).read
    end
  end
end
