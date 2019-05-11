# frozen_string_literal: true

module ProformaService
  class Export < ServiceBase
    def initialize(exercise: nil)
      @exercise = exercise
    end

    def execute
      create_task
      exporter = Proforma::Exporter.new(@task)
      exporter.perform
    end

    def create_task
      @task = Proforma::Task.new(
        title: @exercise.title,
        description: @exercise.descriptions.first.text,
        internal_description: @exercise.instruction,
        proglang: proglang,
        files: files,
        tests: tests,
        uuid: @exercise.uuid,
        parent_uuid: @exercise.clone_relations.first&.origin&.uuid,
        language: @exercise.descriptions.first.language,
        model_solutions: model_solutions
      )
    end

    def proglang
      {name: @exercise.execution_environment.language, version: @exercise.execution_environment.version}
    end

    def model_solutions
      @exercise.exercise_files.filter { |file| file.role == 'Reference Implementation' }.map do |file|
        # attr_accessor :id, :files, :description, :internal_description

        Proforma::ModelSolution.new(
          id: "ms-#{file.id}",
          files: [
            Proforma::TaskFile.new(
              id: file.id,
              content: file.content,
              filename: file.full_file_name,
              used_by_grader: false,
              usage_by_lms: 'display',
              visible: 'delayed',
              binary: false,
              internal_description: file.role
            )
          ]
        )
      end
    end

    def tests
      @exercise.tests.map do |test|
        # :id, :title, :description, :internal_description, :test_type, :files, :meta_data

        Proforma::Test.new(
          id: test.id,
          title: test.exercise_file.name,
          # description: '',
          # internal_description: '',
          # test_type: '',
          files: test_file(test.exercise_file),
          meta_data: {
            'feedback-message' => test.feedback_message,
            'testing-framework' => test.testing_framework.name,
            'testing-framework-version' => test.testing_framework.version
          }.compact
        )
      end
    end

    def test_file(file)
      [Proforma::TaskFile.new(
        id: file.id,
        content: file.content,
        filename: file.full_file_name,
        used_by_grader: true,
        visible: file.hidden ? 'no' : 'yes',
        binary: false,
        internal_description: file.role || 'Teacher-defined Test'
      )]
    end

    def files
      @exercise.exercise_files
               .filter { |file| file.role != 'Reference Implementation' && !file.in?(@exercise.tests.map(&:exercise_file)) }.map do |file|
        if file.attachment.exists?
          bin_content = Paperclip.io_adapters.for(file.attachment).read
          Proforma::TaskFile.new(
            id: file.id,
            content: bin_content,
            filename: file.full_file_name,
            used_by_grader: false,
            usage_by_lms: file.read_only ? 'display' : 'edit',
            visible: file.hidden ? 'no' : 'yes',
            binary: true,
            internal_description: file.role || 'Regular File',
            mimetype: file.attachment_content_type
          )
        else
          Proforma::TaskFile.new(
            id: file.id,
            content: file.content,
            filename: file.full_file_name,
            used_by_grader: true,
            usage_by_lms: file.read_only ? 'display' : 'edit',
            visible: file.hidden ? 'no' : 'yes',
            binary: false,
            internal_description: file.role || 'Regular File'
          )
        end
      end
    end
  end
end
