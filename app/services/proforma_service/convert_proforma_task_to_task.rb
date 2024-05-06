# frozen_string_literal: true

module ProformaService
  class ConvertProformaTaskToTask < ServiceBase
    def initialize(proforma_task:, user:, task: nil)
      super()
      @proforma_task = proforma_task
      @user = user
      @task = task || Task.new
    end

    def execute
      import_task
      @task
    end

    private

    def import_task
      @task.assign_attributes(
        user: @user,
        title: @proforma_task.title,
        description:,
        internal_description: @proforma_task.internal_description,
        programming_language:,
        uuid:,
        parent_uuid: @proforma_task.parent_uuid,
        language: @proforma_task.language,
        meta_data: @proforma_task.meta_data,

        submission_restrictions: @proforma_task.submission_restrictions,
        external_resources: @proforma_task.external_resources,
        grading_hints: @proforma_task.grading_hints,

        tests:,
        model_solutions:,
        files: files.values # this line has to be last, because tests and model_solutions have to remove their respective files first
      )
    end

    def uuid
      @task.uuid || @proforma_task.uuid
    end

    def description
      Kramdown::Document.new(@proforma_task.description || '', html_to_native: true, line_width: -1).to_kramdown.strip
    end

    def files
      @files ||= @proforma_task.all_files.reject {|file| file.id == 'ms-placeholder-file' }.to_h do |task_file|
        [task_file.id, file_from_proforma_file(task_file)]
      end
    end

    def file_from_proforma_file(proforma_task_file)
      task_file = TaskFile.new(file_attributes(proforma_task_file))
      if proforma_task_file.binary
        task_file.attachment.attach(io: StringIO.new(proforma_task_file.content), filename: proforma_task_file.filename,
          content_type: proforma_task_file.mimetype)
        task_file.use_attached_file = 'true'
      else
        task_file.content = proforma_task_file.content
      end
      task_file
    end

    def file_attributes(proforma_task_file)
      {
        full_file_name: proforma_task_file.filename,
        internal_description: proforma_task_file.internal_description,
        used_by_grader: proforma_task_file.used_by_grader,
        visible: proforma_task_file.visible,
        usage_by_lms: proforma_task_file.usage_by_lms,
        mime_type: proforma_task_file.mimetype,
        xml_id: proforma_task_file.id,
      }
    end

    def tests
      @proforma_task.tests.map do |test|
        Test.new(
          xml_id: test.id,
          title: test.title,
          description: test.description,
          internal_description: test.internal_description,
          test_type: test.test_type,
          meta_data: test.meta_data,
          configuration: test.configuration,
          files: object_files(test)
        )
      end
    end

    def object_files(object)
      object.files.map {|file| files.delete(file.id) }
    end

    def programming_language # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      proglang_name = @proforma_task.proglang&.dig(:name).try(:downcase)
      proglang_version = @proforma_task.proglang&.dig(:version).try(:downcase)&.to_s
      return @task.programming_language if proglang_name.nil? || proglang_version.nil?

      ProgrammingLanguage.where('LOWER(language) = ? AND LOWER(version) = ?', proglang_name, proglang_version).first_or_initialize do |pl|
        pl.language = @proforma_task.proglang&.dig(:name)
        pl.version = @proforma_task.proglang&.dig(:version)
      end
    end

    def model_solutions
      @proforma_task.model_solutions.map do |model_solution|
        ModelSolution.new(
          xml_id: model_solution.id,
          description: model_solution.description,
          internal_description: model_solution.internal_description,
          files: object_files(model_solution)
        )
      end
    end
  end
end
