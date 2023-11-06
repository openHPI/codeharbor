# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ConvertProformaTaskToTask do
  describe '.new' do
    subject(:convert_to_task_service) { described_class.new(proforma_task:, user:, task:) }

    let(:proforma_task) { ProformaXML::Task.new }
    let(:user) { build(:user) }
    let(:task) { build(:task) }

    it 'assigns proforma_task' do
      expect(convert_to_task_service.instance_variable_get(:@proforma_task)).to be proforma_task
    end

    it 'assigns user' do
      expect(convert_to_task_service.instance_variable_get(:@user)).to be user
    end

    it 'assigns task' do
      expect(convert_to_task_service.instance_variable_get(:@task)).to be task
    end
  end

  describe '#execute' do
    subject(:convert_to_task_service) { described_class.call(proforma_task:, user:, task:) }

    let(:proforma_task) do
      ProformaXML::Task.new(
        title: 'title',
        description:,
        internal_description: 'internal_description',
        proglang: {name: 'proglang-name', version: 'proglang-version'},
        uuid:,
        parent_uuid: 'parent_uuid',
        language: 'en',
        meta_data:,
        submission_restrictions:,
        external_resources:,
        grading_hints:,
        model_solutions:,
        files:,
        tests:
      )
    end

    let(:uuid) { SecureRandom.uuid }
    let(:description) { 'description' }
    let(:user) { build(:user) }
    let(:meta_data) {}
    let(:submission_restrictions) {}
    let(:external_resources) {}
    let(:grading_hints) {}
    let(:files) { [] }
    let(:tests) { [] }
    let(:model_solutions) { [] }
    let(:task) {}

    it 'creates a task with the correct attributes' do
      expect(convert_to_task_service).to have_attributes(
        title: 'title',
        description: 'description',
        internal_description: 'internal_description',
        programming_language: be_an(ProgrammingLanguage).and(have_attributes(language: 'proglang-name', version: 'proglang-version')),
        uuid: proforma_task.uuid,
        parent_uuid: be_blank,
        language: 'en',
        files: be_empty,
        tests: be_empty,
        model_solutions: be_empty
      )
    end

    context 'when description contains html' do
      let(:description) { '<p>description</p>' }

      it 'creates a task with a correct description' do
        expect(convert_to_task_service).to have_attributes(
          description: 'description'
        )
      end

      context 'with a html entity' do
        let(:description) { '<p>descr&uuml;ption</p>' }

        it 'creates a task with a correct description' do
          expect(convert_to_task_service).to have_attributes(
            description: 'descrüption'
          )
        end
      end
    end

    context 'with meta_data' do
      let(:meta_data) do
        {
          '@@order' => %w[CodeOcean],
          'CodeOcean' => {
            '@@order' => %w[meta nested],
            'meta' => 'data',
            'nested' => {
              '@@order' => %w[other],
              'other' => 'data',
            },
          },
        }
      end

      it 'creates a task with meta_data' do
        expect(convert_to_task_service).to have_attributes(meta_data:)
      end
    end

    context 'when proforma_task has a file' do
      let(:files) { [file] }
      let(:file) do
        ProformaXML::TaskFile.new(
          id: 'id',
          content:,
          filename: 'filename.txt',
          used_by_grader: false,
          visible:,
          usage_by_lms:,
          binary:,
          internal_description: 'internal_description',
          mimetype:
        )
      end
      let(:usage_by_lms) { 'display' }
      let(:mimetype) { 'mimetype' }
      let(:binary) { false }
      let(:content) { 'content' }
      let(:visible) { 'yes' }

      it 'creates a task with a file that has the correct attributes' do
        expect(convert_to_task_service.files.first).to have_attributes(
          content: 'content',
          path: '',
          name: file.filename,
          internal_description: file.internal_description,
          mime_type: file.mimetype,
          used_by_grader: file.used_by_grader,
          visible: file.visible,
          usage_by_lms: file.usage_by_lms,
          xml_id: file.id
        )
      end

      it 'creates a new Task on save' do
        expect { convert_to_task_service.save }.to change(Task, :count).by(1)
      end

      context 'when visible is no' do
        let(:visible) { 'no' }

        it 'creates a task with a hidden file' do
          expect(convert_to_task_service.files.first).to have_attributes(visible: 'no')
        end
      end

      context 'when visible is delayed' do
        let(:visible) { 'delayed' }

        it 'creates a task with a hidden file' do
          expect(convert_to_task_service.files.first).to have_attributes(visible: 'delayed')
        end
      end

      context 'when file is very large' do
        let(:content) { 'test' * (10**5) }

        it 'creates a task with a file that has the correct attributes' do
          expect(convert_to_task_service.files.first).to have_attributes(content:)
        end
      end

      context 'when file is binary' do
        let(:mimetype) { 'image/png' }
        let(:binary) { true }

        it 'creates a task with an task_file with has the file attached' do
          expect(convert_to_task_service.files.first.attachment).to be_attached
        end
      end

      context 'when usage_by_lms is edit' do
        let(:usage_by_lms) { 'edit' }

        it 'creates a task with a file with correct attributes' do
          expect(convert_to_task_service.files.first).to have_attributes(usage_by_lms: 'edit')
        end
      end

      context 'when file is a model-solution-placeholder (needed by proforma until issue #5 is resolved)' do
        let(:file) { ProformaXML::TaskFile.new(id: 'ms-placeholder-file') }

        it 'leaves files empty' do
          expect(convert_to_task_service.files).to be_empty
        end
      end
    end

    context 'when proforma_task has a model-solution' do
      let(:model_solutions) { [model_solution] }
      let(:model_solution) do
        ProformaXML::ModelSolution.new(
          id: 'ms-id',
          description: 'description',
          internal_description: 'internal-description',
          files: ms_files
        )
      end
      let(:ms_files) { [ms_file] }
      let(:ms_file) do
        ProformaXML::TaskFile.new(
          id: 'ms-file',
          content: 'content',
          filename: 'filename.txt',
          used_by_grader: false,
          visible: 'yes',
          usage_by_lms: 'display',
          binary: false
        )
      end

      it 'creates a task with a model-solution' do
        expect(convert_to_task_service.model_solutions).to have(1).item
      end

      it 'creates a task with a model_solution with correct attributes' do
        expect(convert_to_task_service.model_solutions.first).to have_attributes(
          description: model_solution.description,
          internal_description: model_solution.internal_description,
          xml_id: model_solution.id,
          files: have_exactly(1).item.and(all(have_attributes(
            content: ms_file.content,
            name: ms_file.filename,
            used_by_grader: ms_file.used_by_grader,
            visible: ms_file.visible,
            usage_by_lms: ms_file.usage_by_lms
          )))
        )
      end

      context 'when proforma_task has two model-solutions' do
        let(:model_solutions) { [model_solution, ProformaXML::ModelSolution.new(id: 'ms-id-2', files: [])] }

        it 'creates a task with two model-solutions' do
          expect(convert_to_task_service.model_solutions).to have(2).items
        end
      end
    end

    context 'without tests' do
      let(:tests) { [] }

      it 'creates a task without a test' do
        expect(convert_to_task_service.tests).to have(0).item
      end
    end

    context 'when proforma_task has a test' do
      let(:tests) { [test] }
      let(:test) do
        ProformaXML::Test.new(
          id: 'test-id',
          title: 'title',
          description: 'description',
          internal_description: 'internal_description',
          test_type: 'test_type',
          files: test_files,
          meta_data: test_meta_data
        )
      end

      let(:test_meta_data) {}
      let(:test_files) { [test_file] }
      let(:test_file) do
        ProformaXML::TaskFile.new(
          id: 'test_file_id',
          content: 'testfile-content',
          filename: 'testfile.txt',
          used_by_grader: true,
          visible: 'no',
          usage_by_lms: 'display',
          binary: false,
          internal_description: 'teacher_defined_test'
        )
      end

      it 'creates a task with a test' do
        expect(convert_to_task_service.tests).to have(1).item
      end

      it 'creates a task with a test with correct attributes' do
        expect(convert_to_task_service.tests.first).to have_attributes(
          title: test.title,
          description: test.description,
          internal_description: test.internal_description,
          xml_id: test.id,
          files: all(have_attributes(
            content: test_file.content,
            internal_description: test_file.internal_description,
            name: test_file.filename,
            used_by_grader: test_file.used_by_grader,
            visible: test_file.visible,
            usage_by_lms: test_file.usage_by_lms
          ))
        )
      end

      context 'without test has no files' do
        let(:test_files) { [] }

        it 'creates a task with a test without files' do
          expect(convert_to_task_service.tests.first.files).to have(0).item
        end
      end

      context 'when test has multiple files' do
        let(:test_files) { [test_file, test_file2] }
        let(:test_file2) do
          ProformaXML::TaskFile.new(
            id: 'test_file2_id',
            content: 'testfile2-content',
            filename: 'testfile2.txt',
            used_by_grader: 'yes',
            visible: 'no',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'teacher_defined_test'
          )
        end

        it 'creates a task with a test' do
          expect(convert_to_task_service.tests).to have(1).item
        end

        it 'creates a task with a test with two files' do
          expect(convert_to_task_service.tests.first).to have_attributes(files: have(2).items)
        end
      end

      context 'when test has meta_data' do
        let(:test_meta_data) { attributes_for(:test, :with_meta_data)[:meta_data] }

        it 'creates a test with meta_data' do
          expect(convert_to_task_service.tests.first).to have_attributes(meta_data: test_meta_data)
        end
      end

      context 'when test has custom configuration' do
        let(:test) { build(:test, :with_unittest) }

        it 'creates a test with the supplied test configuration' do
          expect(convert_to_task_service.tests.first).to have_attributes(configuration: test.configuration)
        end
      end

      context 'when test has multiple custom configuration' do
        let(:test) { build(:test, :with_multiple_custom_configurations) }

        it 'creates a test with the supplied test configurations' do
          expect(convert_to_task_service.tests.first).to have_attributes(configuration: test.configuration)
        end
      end

      context 'when proforma_task has multiple tests' do
        let(:tests) { [test, test2] }
        let(:test2) do
          ProformaXML::Test.new(files: test_files2)
        end
        let(:test_files2) { [test_file2] }
        let(:test_file2) do
          ProformaXML::TaskFile.new(
            id: 'test_file_id2',
            content: 'testfile-content',
            filename: 'testfile.txt',
            used_by_grader: 'yes',
            visible: 'no',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'teacher_defined_test'
          )
        end

        it 'creates a task with two test' do
          expect(convert_to_task_service.tests).to have(2).items
        end
      end
    end

    context 'when task has submission_restrictions' do
      let(:submission_restrictions_hash) { attributes_for(:task, :with_submission_restrictions)[:submission_restrictions] }
      let(:submission_restrictions) { submission_restrictions_hash }

      it 'creates a task with correct submission_restrictions' do
        expect(convert_to_task_service).to have_attributes(submission_restrictions: submission_restrictions_hash)
      end
    end

    context 'when task has external_resources' do
      let(:external_resources_hash) { attributes_for(:task, :with_external_resources)[:external_resources] }
      let(:external_resources) { external_resources_hash }

      it 'creates a task with correct external_resources' do
        expect(convert_to_task_service).to have_attributes(external_resources: external_resources_hash)
      end
    end

    context 'when task has grading_hints' do
      let(:grading_hints_hash) { attributes_for(:task, :with_grading_hints)[:grading_hints] }
      let(:grading_hints) { grading_hints_hash }

      it 'creates a task with correct grading_hints' do
        expect(convert_to_task_service).to have_attributes(grading_hints: grading_hints_hash)
      end
    end

    context 'when task is set' do
      let(:task) do
        create(
          :task,
          title: 'task-title',
          description: 'task-description',
          internal_description: 'task-internal_description'
        )
      end

      before { task.reload }

      it 'assigns all values to given task' do
        convert_to_task_service.save
        expect(task.reload).to have_attributes(
          id: task.id,
          title: proforma_task.title,
          description: Kramdown::Document.new(proforma_task.description, html_to_native: true).to_kramdown.strip,
          internal_description: proforma_task.internal_description,
          programming_language: have_attributes(language: proforma_task.proglang[:name], version: proforma_task.proglang[:version]),
          uuid: task.uuid,
          parent_uuid: be_blank,
          language: 'en',

          files: be_empty,
          tests: be_empty,
          model_solutions: be_empty
        )
      end

      it 'does not create a new Task on save' do
        expect { convert_to_task_service.save }.not_to change(Task, :count)
      end

      context 'with file, model solution and test' do
        let(:files) { [file] }
        let(:file) do
          ProformaXML::TaskFile.new(
            id: 'id',
            content: 'content',
            filename: 'filename.txt',
            used_by_grader: 'used_by_grader',
            visible: 'yes',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'internal_description'
          )
        end
        let(:tests) { [test] }
        let(:test) do
          ProformaXML::Test.new(
            id: 'test-id',
            title: 'title',
            description: 'description',
            internal_description: 'internal_description',
            test_type: 'test_type',
            files: test_files
          )
        end
        let(:test_files) { [test_file] }
        let(:test_file) do
          ProformaXML::TaskFile.new(
            id: 'test_file_id',
            content: 'testfile-content',
            filename: 'testfile.txt',
            used_by_grader: 'yes',
            visible: 'no',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'teacher_defined_test'
          )
        end
        let(:model_solutions) { [model_solution] }
        let(:model_solution) do
          ProformaXML::ModelSolution.new(
            id: 'ms-id',
            description: 'ms-description',
            files: ms_files
          )
        end
        let(:ms_files) { [ms_file] }
        let(:ms_file) do
          ProformaXML::TaskFile.new(
            id: 'ms-file',
            content: 'ms-content',
            filename: 'ms-filename.txt',
            used_by_grader: 'used_by_grader',
            visible: 'yes',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'reference_implementation'
          )
        end

        it 'assigns all values to given task' do
          expect(convert_to_task_service).to have_attributes(
            id: task.id,
            files: have(1).item.and(include(have_attributes(content: 'content'))),
            model_solutions: have(1).item
              .and(include(have_attributes(description: model_solution.description,
                files: include(have_attributes(content: ms_file.content))))),
            tests: have(1).item
              .and(include(have_attributes(title: test.title, files: include(have_attributes(content: test_file.content)))))
          )
        end
      end
    end
  end
end
