# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ExportTask do
  describe '.new' do
    subject(:export_service) { described_class.new(exercise: exercise) }

    let(:exercise) { build(:exercise) }

    it 'assigns exercise' do
      expect(export_service.instance_variable_get(:@exercise)).to be exercise
    end
  end

  describe '#execute' do
    subject(:execute) { export_service.execute }

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

    let(:zip_files) do
      {}.tap do |hash|
        Zip::InputStream.open(execute) do |io|
          while (entry = io.get_next_entry)
            hash[entry.name] = entry.get_input_stream.read
          end
        end
      end
    end
    let(:doc) { Nokogiri::XML(zip_files['task.xml'], &:noblanks) }
    let(:xml) { doc.remove_namespaces! }

    it_behaves_like 'zipped task node xml'

    it 'adds title node with correct content to task node' do
      expect(xml.xpath('/task/title').text).to eql exercise.title
    end

    it 'adds description node with correct content to task node' do
      expect(xml.xpath('/task/description').text).to eql Kramdown::Document.new(
        exercise.descriptions.select(&:primary).first.text
      ).to_html.strip
    end

    it 'adds proglang node with correct content to task node' do
      expect(xml.xpath('/task/proglang').text).to eql exercise.execution_environment.language
    end

    it 'adds version attribute to proglang node' do
      expect(xml.xpath('/task/proglang').attribute('version').value).to eql exercise.execution_environment.version
    end

    it 'adds internal-description node with correct content to task node' do
      expect(xml.xpath('/task/internal-description').text).to eql exercise.instruction
    end

    it 'adds uuid attribute to task node' do
      expect(xml.xpath('/task').attribute('uuid').value).to eql exercise.uuid
    end

    context 'when exercise is minimal' do
      let(:exercise) do
        create(:exercise,
               :empty,
               title: 'title',
               descriptions: build_list(:simple_description, 1, :primary),
               execution_environment: build(:java_8_execution_environment))
      end

      it_behaves_like 'zipped task node xml'
    end

    context 'when exercise has a mainfile' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_main_file) }

      it_behaves_like 'task node with file'

      context 'when the mainfile is very large' do
        let(:file) { build(:codeharbor_main_file, content: 'test' * 10**5) }

        it 'adds a attached-txt-file node to the file node' do
          expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/attached-txt-file")).to have(1).item
        end

        it 'adds attached file to zip' do
          expect(zip_files[file.full_file_name]).not_to be nil
        end
      end
    end

    context 'when exercise has a regular file' do
      let(:files) { [file] }
      let(:file) { build(:codeharbor_regular_file) }

      it_behaves_like 'task node with file'

      context 'when file has an attachment' do
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
        expect(xml.xpath('/task/files/file').attribute('visible').value).to eql 'yes'
      end

      it 'adds correct role to internal-description of the  referenced file node' do
        expect(xml.xpath('/task/files/file/internal-description').text).to eql file.role
      end
    end

    context 'when exercise has multiple files with role reference implementation' do
      let(:files) { build_list(:codeharbor_solution_file, 2) }

      it 'adds test node to tests node' do
        expect(xml.xpath('/task/model-solutions/model-solution')).to have(2).items
      end
    end

    context 'when exercise has a test' do
      let(:tests) { [test] }
      let(:test) { build(:codeharbor_test) }

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
      let(:tests) { build_list(:codeharbor_test, 2) }

      it 'adds test node to tests node' do
        expect(xml.xpath('/task/tests/test')).to have(2).item
      end
    end

    context 'when exercise has multiple descriptions' do
      let(:exercise) do
        create(:exercise, descriptions: [build(:description), build(:description), build(:description, :primary)])
      end

      it 'adds description node with correct content to task node' do
        expect(xml.xpath('/task/description').text).to include exercise.descriptions.select(&:primary).first.text
      end
    end
  end
end
