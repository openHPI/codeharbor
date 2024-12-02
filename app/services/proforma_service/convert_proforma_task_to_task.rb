# frozen_string_literal: true

module ProformaService
  class ConvertProformaTaskToTask < ServiceBase
    def initialize(proforma_task:, user:, task: nil)
      super()
      @proforma_task = proforma_task
      @user = user
      @task = task || Task.new
      @all_files = @task.all_files
      @file_xml_ids = []
    end

    def execute
      ActiveRecord::Base.transaction do
        import_task
      end
      @task
    end

    private

    def import_task
      @task.assign_attributes(
        user:,
        title: @proforma_task.title,
        description:,
        internal_description: @proforma_task.internal_description,
        programming_language:,
        uuid:,
        parent_uuid:,
        language: @proforma_task.language,
        meta_data: @proforma_task.meta_data,

        submission_restrictions: @proforma_task.submission_restrictions,
        external_resources: @proforma_task.external_resources,
        grading_hints: @proforma_task.grading_hints
      )
      @task.save!
      @task.reload
      @task.files = @all_files # @task.files + unreferenced_files
      @task.reload
      tests
      @task.reload
      model_solutions

      @task.reload
      @all_files = @task.files
      upsert_files @proforma_task, @task
      # Currently files on task do not get deleted.
      # find all removed files first and move only those to task (and then further as necessary) that way updated_at does not get set
      # upsert, then delete unwanted files (by comparing xml_ids)
      delete_removed_files
      delete_removed_objects
      @task.save!
    end

    def all_proforma_files
      [@proforma_task.files + @proforma_task.tests.map(&:files) + @proforma_task.model_solutions.map(&:files)].flatten
    end

    def unreferenced_files
      @task.all_files.filter do |f|
        all_proforma_files.map {|pf| pf.id.to_s }.include?(f.xml_id)
      end
    end

    def parent_uuid
      @proforma_task.parent_uuid || @task.parent_uuid
    end

    def user
      @task.user || @user
    end

    def uuid
      @task.uuid || @proforma_task.uuid
    end

    def description
      Kramdown::Document.new(@proforma_task.description || '', html_to_native: true, line_width: -1).to_kramdown.strip
    end

    def upsert_files(collection, fileable)
      collection.files.map {|task_file| upsert_file_from_proforma_file(task_file, fileable) }
    end

    def upsert_file_from_proforma_file(proforma_task_file, fileable)
      task_file = ch_record_for(@all_files, proforma_task_file.id) || TaskFile.new
      task_file.assign_attributes(file_attributes(proforma_task_file, fileable))
      attach_file_content(proforma_task_file, task_file)
      task_file
    end

    def attach_file_content(proforma_task_file, task_file)
      if proforma_task_file.binary
        task_file.attachment.attach(
          io: StringIO.new(proforma_task_file.content),
          filename: proforma_task_file.filename,
          content_type: proforma_task_file.mimetype
        )
        task_file.use_attached_file = 'true'
      else
        task_file.content = proforma_task_file.content
        task_file.use_attached_file = 'false'
      end
    end

    def xml_file_id(xml_id)
      return xml_id unless @file_xml_ids.include?(xml_id)

      offset = 2
      offset += 1 while @file_xml_ids.include?("#{xml_id}-#{offset}")
      "#{xml_id}-#{offset}"
    end

    def file_attributes(proforma_task_file, fileable)
      xml_id = xml_file_id proforma_task_file.id
      @file_xml_ids << xml_id
      {
        full_file_name: proforma_task_file.filename,
        internal_description: proforma_task_file.internal_description,
        used_by_grader: proforma_task_file.used_by_grader,
        visible: proforma_task_file.visible,
        usage_by_lms: proforma_task_file.usage_by_lms,
        mime_type: proforma_task_file.mimetype,
        xml_id:,
        fileable:,
      }
    end

    def tests
      @proforma_task.tests.each do |test|
        ch_test = ch_record_for(@task.tests, test.id) || Test.new(xml_id: test.id)
        ch_test.task = @task
        upsert_files test, ch_test
        ch_test.assign_attributes(
          title: test.title,
          description: test.description,
          internal_description: test.internal_description,
          test_type: test.test_type,
          meta_data: test.meta_data,
          configuration: test.configuration
        )
        ch_test.save!
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
      @proforma_task.model_solutions.each do |model_solution|
        ch_model_solution = ch_record_for(@task.model_solutions, model_solution.id) || ModelSolution.new(xml_id: model_solution.id)
        ch_model_solution.task = @task
        upsert_files model_solution, ch_model_solution
        ch_model_solution.assign_attributes(
          description: model_solution.description,
          internal_description: model_solution.internal_description
        )
        ch_model_solution.save!
      end
    end

    def ch_record_for(collection, xml_id)
      collection.select {|record| record.xml_id == xml_id }&.first
    end

    def delete_removed_files
      @all_files.reject {|file| @file_xml_ids.map(&:to_s).include? file.xml_id }.each(&:destroy)
    end

    def delete_removed_objects
      @task.tests.reject {|test| @proforma_task.tests.map {|t| t.id.to_s }.include? test.xml_id }.each(&:destroy)
      @task.model_solutions.reject do |model_solution|
        @proforma_task.model_solutions.map {|ms| ms.id.to_s }.include? model_solution.xml_id
      end.each(&:destroy)
    end
  end
end
