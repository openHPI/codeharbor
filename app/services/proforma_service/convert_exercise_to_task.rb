# frozen_string_literal: true

module ProformaService
  class ConvertExerciseToTask < ServiceBase
    def initialize(exercise: nil)
      @exercise = exercise
    end

    def execute
      create_task
    end

    private

    def create_task
      Proforma::Task.new(
        {
          title: @exercise.title,
          description: primary_description.text,
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

    def parent_uuid
      @exercise.clone_relations.first&.origin&.uuid
    end

    def primary_description
      @exercise.descriptions.select(&:primary?).first
    end

    def proglang
      {name: @exercise.execution_environment.language, version: @exercise.execution_environment.version}
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
        Proforma::Test.new(
          id: test.id,
          title: test.exercise_file.name,
          files: test_file(test.exercise_file),
          meta_data: {
            'feedback-message' => test.feedback_message,
            'testing-framework' => test.testing_framework&.name,
            'testing-framework-version' => test.testing_framework&.version
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
        internal_description: file.role || 'teacher_defined_test'
      )]
    end

    def task_files
      @exercise.exercise_files
               .filter { |file| file.role != 'reference_implementation' && !file.in?(@exercise.tests.map(&:exercise_file)) }.map do |file|
        task_file(file)
      end
    end

    def task_file(file)
      Proforma::TaskFile.new(
        {
          id: file.id,
          filename: file.full_file_name,
          usage_by_lms: file.read_only ? 'display' : 'edit',
          visible: file.hidden ? 'no' : 'yes',
          internal_description: file.role || 'Regular File'
        }.tap do |params|
          if file.attachment.exists?
            params[:content] = attachment_content(file)
            params[:used_by_grader] = false
            params[:binary] = true
            params[:mimetype] = file.attachment_content_type
          else
            params[:content] = file.content
            params[:used_by_grader] = true
            params[:binary] = false
          end
        end
      )
    end

    def attachment_content(file)
      Paperclip.io_adapters.for(file.attachment).read
    end
  end
end
