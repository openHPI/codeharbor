# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ConvertExerciseToTask do
  describe '.new' do
    subject(:export_service) { described_class.new(exercise: exercise) }

    let(:exercise) { build(:exercise) }

    it 'assigns exercise' do
      expect(export_service.instance_variable_get(:@exercise)).to be exercise
    end
  end

  describe '#execute' do
    subject(:task) { export_service.execute }

    let(:export_service) { described_class.new(exercise: exercise) }
    let(:exercise) do
      create(:exercise,
             instruction: 'instruction',
             uuid: SecureRandom.uuid,
             exercise_files: files,
             tests: tests)
    end
    let(:files) { [] }
    let(:tests) { [] }

    it 'creates a task with all basic attributes' do
      expect(task).to have_attributes(
        title: exercise.title,
        description: exercise.descriptions.select(&:primary?).first.text,
        internal_description: exercise.instruction,
        proglang: {
          name: exercise.execution_environment.language,
          version: exercise.execution_environment.version
        },
        uuid: exercise.uuid,
        language: exercise.descriptions.select(&:primary?).first.language,
        parent_uuid: exercise.clone_relations.first&.origin&.uuid,
        files: [],
        tests: [],
        model_solutions: []
      )
    end

    context 'when exercise has a mainfile' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_main_file) }

      it 'creates a task-file with the correct attributes' do
        expect(task.files.first).to have_attributes(
          id: file.id,
          content: file.content,
          filename: file.full_file_name,
          used_by_grader: true,
          usage_by_lms: 'edit',
          visible: 'yes',
          binary: false,
          internal_description: 'Main File'
        )
      end
    end

##TODO
    fcontext 'when exercise has a regular file' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_regular_file) }


      xcontext 'when file has an attachment' do
        let(:file) { build(:codeharbor_regular_file, :with_attachment) }

        it 'adds a embedded-bin-file node to the file node' do
          expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/embedded-bin-file")).to have(1).item
        end
      end
    end

    context 'when exercise has a file with role reference implementation' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_solution_file) }

      it 'adds id attribute to model-solution node' do
        expect(xml.xpath('/task/model-solutions/model-solution').attribute('id').value).to eql "ms-#{file.id}"
      end

      it 'adds correct refid attribute to fileref' do
        expect(
          xml.xpath('/task/model-solutions/model-solution/filerefs/fileref').attribute('refid').value
        ).to eql xml.xpath('/task/files/file').attribute('id').value
      end

      it 'adds description attribute to model-solution' do
        expect(xml.xpath('/task/model-solutions/model-solution/description').text).to be_empty
      end

      it 'adds internal-description attribute to model-solution' do
        expect(xml.xpath('/task/model-solutions/model-solution/internal-description').text).to be_empty
      end

      it 'adds correct used-by-grader attribute to the referenced file node' do
        expect(xml.xpath('/task/files/file').attribute('used-by-grader').value).to eql 'false'
      end

      it 'adds correct usage-by-lms attribute to the referenced file node' do
        expect(xml.xpath('/task/files/file').attribute('usage-by-lms').value).to eql 'display'
      end

      it 'adds correct visible attribute to the referenced file node' do
        expect(xml.xpath('/task/files/file').attribute('visible').value).to eql 'delayed'
      end

      it 'adds correct role to internal-description of the  referenced file node' do
        expect(xml.xpath('/task/files/file/internal-description').text).to eql file.role
      end
    end

    context 'when exercise has multiple files with role reference implementation' do
      let(:files) { create_list(:codeharbor_solution_file, 2) }

      it 'adds test node to tests node' do
        expect(xml.xpath('/task/model-solutions/model-solution')).to have(2).item
      end
    end

    context 'when exercise has a test' do
      let(:tests) { [test] }
      let(:test) { create(:codeharbor_test) }

      it 'adds test node to tests node' do
        expect(xml.xpath('/task/tests/test')).to have(1).item
      end

      it 'adds id attribute to tests node' do
        expect(xml.xpath('/task/tests/test').attribute('id').value).to eql test.id.to_s
      end

      it 'adds correct title node to test node' do
        expect(xml.xpath('/task/tests/test/title').text).to eql test.exercise_file.name
      end

      it 'adds fileref node' do
        expect(xml.xpath('/task/tests/test/test-configuration/filerefs/fileref')).to have(1).item
      end

      it 'adds correct refid attribute to fileref' do
        expect(
          xml.xpath('/task/tests/test/test-configuration/filerefs/fileref').attribute('refid').value
        ).to eql xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('id').value
      end

      it 'adds feedback-message with codeharbor namespace to test-meta-data node' do
        expect(
          doc.xpath('/xmlns:task/xmlns:tests/xmlns:test/xmlns:test-configuration/xmlns:test-meta-data/c:feedback-message').text
        ).to eql test.feedback_message
      end

      it 'adds testing-framework with codeharbor namespace to test-meta-data node' do
        expect(
          doc.xpath('/xmlns:task/xmlns:tests/xmlns:test/xmlns:test-configuration/xmlns:test-meta-data/c:testing-framework').text
        ).to eql test.testing_framework.name
      end

      it 'adds testing-framework-version with codeharbor namespace to test-meta-data node' do
        expect(
          doc.xpath('/xmlns:task/xmlns:tests/xmlns:test/xmlns:test-configuration/xmlns:test-meta-data/c:testing-framework-version').text
        ).to eql test.testing_framework.version
      end
    end

    context 'when exercise has multiple tests' do
      let(:tests) { create_list(:codeharbor_test, 2) }

      it 'adds test node to tests node' do
        expect(xml.xpath('/task/tests/test')).to have(2).item
      end
    end

    context 'when exercise has multiple descriptions' do
      let(:exercise) do
        create(:exercise, descriptions: [build(:description), build(:description), build(:description, :primary)])
      end

      it 'adds description node with correct content to task node' do
        expect(xml.xpath('/task/description').text).to eql exercise.descriptions.select(&:primary).first.text
      end
    end
  end
end
