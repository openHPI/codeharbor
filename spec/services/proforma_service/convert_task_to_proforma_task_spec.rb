# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ConvertTaskToProformaTask do
  describe '.new' do
    subject(:convert_to_proforma_task) { described_class.new(task: task, options: options) }

    let(:options) { {} }
    let(:task) { build(:task) }

    it 'assigns task' do
      expect(convert_to_proforma_task.instance_variable_get(:@task)).to be task
    end

    it 'assigns options' do
      expect(convert_to_proforma_task.instance_variable_get(:@options)).to be options
    end
  end

  describe '#execute' do
    subject(:proforma_task) { convert_to_proforma_task.execute }

    let(:convert_to_proforma_task) { described_class.new(task: task) }
    let(:task) do
      create(:task,
             uuid: SecureRandom.uuid,
             parent_uuid: SecureRandom.uuid,
             meta_data: meta_data,
             files: files,
             tests: tests,
             model_solutions: model_solutions,
             programming_language: build(:programming_language),
             description: description)
    end
    let(:description) { 'description' }
    let(:meta_data) {}
    let(:files) { [] }
    let(:tests) { [] }
    let(:model_solutions) { [] }

    it 'creates a task with all basic attributes' do
      expect(proforma_task).to have_attributes(
        title: task.title,
        description: Kramdown::Document.new(task.description).to_html.strip,
        internal_description: task.internal_description,
        proglang: {
          name: task.programming_language.language,
          version: task.programming_language.version
        },
        uuid: task.uuid,
        language: task.language,
        parent_uuid: task.parent_uuid,
        files: [],
        tests: [],
        model_solutions: []
      )
    end

    context 'with options' do
      let(:convert_to_proforma_task) { described_class.new(task: task, options: options) }
      let(:options) { {} }

      it 'converts the description markdown to text' do
        expect(proforma_task).to have_attributes(description: Kramdown::Document.new(task.description).to_html.strip)
      end

      context 'when options contain description_format md' do
        let(:options) { {description_format: 'md'} }

        it 'does not convert the description markdown' do
          expect(proforma_task).to have_attributes(description: task.description)
        end
      end
    end

    context 'when task has meta_data' do
      let(:meta_data) { {CodeOcean: {meta: 'data', nested: {other: 'data'}}} }

      it 'does not convert the description markdown' do
        expect(proforma_task).to have_attributes(meta_data: meta_data)
      end
    end

    context 'when task has a file' do
      let(:files) { [file] }
      let(:file) { build(:task_file, :exportable) }

      it 'creates a task-file with the correct attributes' do
        expect(proforma_task.files.first).to have_attributes(
          id: file.id,
          content: file.content,
          filename: file.full_file_name,
          used_by_grader: file.used_by_grader,
          usage_by_lms: file.usage_by_lms,
          visible: file.visible,
          binary: false,
          internal_description: file.internal_description
        )
      end

      context 'when file has no "usage_by_lms" defined' do
        let(:file) { build(:task_file) }

        it 'creates a task-file with the correct default value' do
          expect(proforma_task.files.first).to have_attributes(usage_by_lms: 'download')
        end
      end

      context 'when file has no "used_by_grader" defined' do
        let(:file) { build(:task_file) }

        it 'creates a task-file with the correct default value' do
          expect(proforma_task.files.first).to have_attributes(used_by_grader: false)
        end
      end

      context 'when file has an attachment' do
        let(:file) { build(:task_file, :with_attachment) }

        it 'creates a task-file with the correct attributes' do
          expect(proforma_task.files.first).to have_attributes(
            used_by_grader: false,
            binary: true,
            mimetype: 'image/bmp'
          )
        end
      end
    end

    context 'when task has model solution' do
      let(:model_solutions) { [model_solution] }
      let(:model_solution) { build(:model_solution, files: ms_files) }
      let(:ms_files) { [] }

      it 'creates a task with one model-solution' do
        expect(proforma_task.model_solutions).to have(1).item
      end

      it 'creates a model-solution with correct attributes' do
        expect(proforma_task.model_solutions.first).to have_attributes(
          description: model_solution.description,
          internal_description: model_solution.internal_description,
          id: model_solution.xml_id,
          files: []
        )
      end

      context 'when model_solution has a file' do
        let(:ms_files) { [ms_file] }
        let(:ms_file) { build(:task_file, :exportable) }

        it 'creates a model-solution with one file with correct attributes' do
          expect(proforma_task.model_solutions.first.files.first).to have_attributes(
            id: ms_file.id,
            content: ms_file.content,
            filename: ms_file.full_file_name,
            used_by_grader: ms_file.used_by_grader,
            usage_by_lms: ms_file.usage_by_lms,
            visible: ms_file.visible,
            binary: false,
            internal_description: ms_file.internal_description
          )
        end
      end

      context 'when model_solution has multiple files' do
        let(:ms_files) { build_list(:task_file, 2) }

        it 'creates a model-solution with 2 files' do
          expect(proforma_task.model_solutions.first.files).to have(2).items
        end
      end

      context 'when task has multiple model_solutions' do
        let(:model_solutions) { build_list(:model_solution, 2) }

        it 'creates a model-solution with 2 tasks' do
          expect(proforma_task.model_solutions).to have(2).items
        end
      end
    end

    context 'when exercise has a test' do
      let(:tests) { [test] }
      let(:test) { build(:test, files: test_files, meta_data: test_meta_data) }
      let(:test_files) { [test_file] }
      let(:test_file) { build(:task_file, :exportable) }
      let(:test_meta_data) {}

      it 'creates a task with one test' do
        expect(proforma_task.tests).to have(1).item
      end

      it 'creates a test with correct attributes and one file' do
        expect(proforma_task.tests.first).to have_attributes(
          id: test.xml_id,
          title: test.title,
          files: have(1).item
        )
      end

      it 'creates a test with one file with correct attributes' do
        expect(proforma_task.tests.first.files.first).to have_attributes(
          id: test_file.id,
          content: test_file.content,
          filename: test_file.full_file_name,
          used_by_grader: test_file.used_by_grader,
          visible: test_file.visible,
          binary: false,
          internal_description: test_file.internal_description
        )
      end

      context 'when test has meta_data' do
        let(:test_meta_data) { {CodeOcean: {meta: 'data', nested: {other: 'data'}}} }

        it 'does not convert the description markdown' do
          expect(proforma_task.tests.first).to have_attributes(meta_data: test_meta_data)
        end
      end

      context 'when test has multiple files' do
        let(:test_files) { [test_file, build(:task_file, :exportable, name: 'file2')] }

        it 'creates a test with correct attributes and one file' do
          expect(proforma_task.tests.first).to have_attributes(
            id: test.xml_id,
            title: test.title,
            files: have(2).item
          )
        end
      end
    end

    context 'when exercise has multiple tests' do
      let(:tests) { build_list(:test, 2) }

      it 'creates a task with two tests' do
        expect(proforma_task.tests).to have(2).items
      end
    end

    context 'when exercise has description formatted in markdown' do
      let(:description) { '# H1 header' }

      it 'creates a task with description and language from primary description' do
        expect(proforma_task).to have_attributes(description: '<h1 id="h1-header">H1 header</h1>')
      end
    end
  end
end
