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
      create(:task, uuid: SecureRandom.uuid, parent_uuid: SecureRandom.uuid, files: files, tests: tests, model_solutions: model_solutions,
                    programming_language: build(:programming_language))
    end
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
      let(:convert_to_proforma_task) { described_class.new(exercise: exercise, options: options) }
      let(:options) { {} } # TODO: descriptions

      context 'when options contain description_format md' do
        let(:options) { {description_format: 'md'} }

        it 'creates a task with all basic attributes' do
          expect(proforma_task).to have_attributes(description: exercise.descriptions.select(&:primary?).first.text)
        end
      end
    end

    context 'when exercise has a mainfile' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_main_file) }

      it 'creates a task-file with the correct attributes' do
        expect(proforma_task.files.first).to have_attributes(
          id: file.id,
          content: file.content,
          filename: file.full_file_name,
          used_by_grader: true,
          usage_by_lms: 'edit',
          visible: 'yes',
          binary: false,
          internal_description: 'main_file'
        )
      end
    end

    context 'when exercise has a regular file' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_regular_file) }

      it 'creates a task-file with the correct attributes' do
        expect(proforma_task.files.first).to have_attributes(
          id: file.id,
          content: file.content,
          filename: file.full_file_name,
          used_by_grader: true,
          usage_by_lms: 'display',
          visible: 'no',
          binary: false,
          internal_description: 'regular_file'
        )
      end

      context 'when file is not hidden' do
        let(:file) { build(:codeharbor_regular_file, hidden: false) }

        it 'creates a task-file with the correct attributes' do
          expect(proforma_task.files.first).to have_attributes(visible: 'yes')
        end
      end

      context 'when file is not read_only' do
        let(:file) { build(:codeharbor_regular_file, read_only: false) }

        it 'creates a task-file with the correct attributes' do
          expect(proforma_task.files.first).to have_attributes(usage_by_lms: 'edit')
        end
      end

      context 'when file has an attachment' do
        let(:file) { build(:codeharbor_regular_file, :with_attachment) }

        it 'creates a task-file with the correct attributes' do
          expect(proforma_task.files.first).to have_attributes(
            used_by_grader: false,
            binary: true,
            mimetype: 'image/bmp'
          )
        end
      end
    end

    context 'when exercise has a file with role reference implementation' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_solution_file) }

      it 'creates a task with one model-solution' do
        expect(proforma_task.model_solutions).to have(1).item
      end

      it 'creates a model-solution with one file' do
        expect(proforma_task.model_solutions.first).to have_attributes(
          id: "ms-#{file.id}",
          files: have(1).item
        )
      end

      it 'creates a model-solution with one file with correct attributes' do
        expect(proforma_task.model_solutions.first.files.first).to have_attributes(
          id: file.id,
          content: file.content,
          filename: file.full_file_name,
          used_by_grader: false,
          usage_by_lms: 'display',
          visible: 'yes',
          binary: false,
          internal_description: 'reference_implementation'
        )
      end
    end

    context 'when exercise has multiple files with role reference implementation' do
      let(:files) { build_list(:codeharbor_solution_file, 2) }

      it 'creates a task with two model-solutions' do
        expect(proforma_task.model_solutions).to have(2).items
      end
    end

    context 'when exercise has a test' do
      let(:tests) { [test] }
      let(:test) { build(:codeharbor_test, exercise_file: file) }
      let(:file) { build(:codeharbor_test_file) }

      it 'creates a task with one test' do
        expect(proforma_task.tests).to have(1).item
      end

      it 'creates a test with correct attributes and one file' do
        expect(proforma_task.tests.first).to have_attributes(
          id: test.id,
          title: file.name,
          files: have(1).item,
          configuration: {
            'entry-point' => file.full_file_name,
            'framework' => test.testing_framework.name,
            'version' => test.testing_framework.version
          },
          meta_data: {
            'feedback-message' => test.feedback_message,
            'testing-framework' => test.testing_framework.name,
            'testing-framework-version' => test.testing_framework.version
          }
        )
      end

      it 'creates a test with one file with correct attributes' do
        expect(proforma_task.tests.first.files.first).to have_attributes(
          id: file.id,
          content: file.content,
          filename: file.full_file_name,
          used_by_grader: true,
          visible: 'no',
          binary: false,
          internal_description: 'teacher_defined_test'
        )
      end

      context 'when exercise_file is not hidden' do
        let(:file) { build(:codeharbor_test_file, hidden: false) }

        it 'creates the test file with the correct attribute' do
          expect(proforma_task.tests.first.files.first).to have_attributes(visible: 'yes')
        end
      end

      context 'when exercise_file has a custom role' do
        let(:file) { build(:codeharbor_test_file, role: 'Very important test') }

        it 'creates the test file with the correct attribute' do
          expect(proforma_task.tests.first.files.first).to have_attributes(internal_description: 'Very important test')
        end
      end

      context 'when test has no testing_framework and feedback_message' do
        let(:test) { build(:codeharbor_test, feedback_message: nil, testing_framework: nil) }

        it 'does not add feedback_message to meta_data' do
          expect(proforma_task.tests.first).to have_attributes(meta_data: {})
        end
      end
    end

    context 'when exercise has multiple tests' do
      let(:tests) { build_list(:codeharbor_test, 2) }

      it 'creates a task with two tests' do
        expect(proforma_task.tests).to have(2).items
      end
    end

    context 'when exercise has description formatted in markdown' do
      let(:exercise) { create(:exercise, descriptions: [build(:description, :primary, text: description, language: 'de')]) }
      let(:description) { '# H1 header' }

      it 'creates a task with description and language from primary description' do
        expect(proforma_task).to have_attributes(description: '<h1 id="h1-header">H1 header</h1>')
      end
    end

    context 'when exercise has multiple descriptions' do
      let(:exercise) do
        create(:exercise,
               descriptions: [
                 build(:description, text: 'desc', language: 'de'),
                 build(:description, text: 'other dec', language: 'ja'),
                 build(:description, :primary, text: 'primary desc', language: 'en')
               ])
      end

      it 'creates a task with description and language from primary description' do
        expect(proforma_task).to have_attributes(
          description: '<p>primary desc</p>',
          language: 'en'
        )
      end
    end
  end
end
