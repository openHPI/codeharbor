# frozen_string_literal: true

require 'rails_helper'

describe ProformaService::ExportTask do
  describe '.new' do
    subject(:export_service) { described_class.new(task: task) }

    let(:task) { build(:task) }

    it 'assigns task' do
      expect(export_service.instance_variable_get(:@task)).to be task
    end
  end

  describe '#execute' do
    subject(:execute) { export_service.execute }

    let(:export_service) { described_class.new(task: task) }
    let(:task) do
      create(:task,
             internal_description: 'internal_description',
             uuid: SecureRandom.uuid,
             programming_language: build(:programming_language, :ruby),
             meta_data: meta_data,
             files: files,
             tests: tests,
             model_solutions: model_solutions)
    end
    let(:meta_data) {}
    let(:files) { [] }
    let(:tests) { [] }
    let(:model_solutions) { [] }

    let(:zip_files) do
      {}.tap do |hash|
        Zip::InputStream.open(execute) do |io|
          while (entry = io.get_next_entry)
            hash[entry.name] = entry.get_input_stream.read
          end
        end
      end
    end
    let(:xml_with_namespaces) { Nokogiri::XML(zip_files['task.xml'], &:noblanks) }
    let(:xml) { Nokogiri::XML(zip_files['task.xml'], &:noblanks).remove_namespaces! }

    it_behaves_like 'zipped task node xml'

    it 'adds title node with correct content to task node' do
      expect(xml.xpath('/task/title').text).to eql task.title
    end

    it 'adds description node with correct content (html) to task node' do
      expect(xml.xpath('/task/description').text).to eql Kramdown::Document.new(task.description).to_html.strip
    end

    it 'adds proglang node with correct content to task node' do
      expect(xml.xpath('/task/proglang').text).to eql task.programming_language.language
    end

    it 'adds version attribute to proglang node' do
      expect(xml.xpath('/task/proglang').attribute('version').value).to eql task.programming_language.version
    end

    it 'adds internal-description node with correct content to task node' do
      expect(xml.xpath('/task/internal-description').text).to eql task.internal_description
    end

    it 'adds uuid attribute to task node' do
      expect(xml.xpath('/task').attribute('uuid').value).to eql task.uuid
    end

    context 'with options' do
      let(:export_service) { described_class.new(task: task, options: options) }
      let(:options) { {} }

      context 'when options contain description_format md' do
        let(:options) { {description_format: 'md'} }

        it 'adds description node with correct content to task node' do
          expect(xml.xpath('/task/description').text).to eql task.description
        end
      end
    end

    context 'when task has meta_data' do
      let(:meta_data) { {CodeOcean: {meta: 'data', nest: {even: {deeper: 'foobar'}}}} }

      it 'adds meta_data node to task node' do
        expect(xml_with_namespaces.xpath('/xmlns:task/xmlns:meta-data/CodeOcean:meta').text).to eql 'data'
      end

      it 'adds nested meta_data node to task node' do
        expect(xml_with_namespaces.xpath('/xmlns:task/xmlns:meta-data/CodeOcean:nest/CodeOcean:even/CodeOcean:deeper').text).to eql 'foobar'
      end
    end

    context 'when task has a file' do
      let(:files) { [file] }
      let(:file) { build(:task_file, :exportable, content: 'filecontent') }

      it_behaves_like 'task node with file'

      context 'when the file is very large' do
        let(:file) { build(:task_file, :exportable, content: 'test' * (10**5)) }

        it 'adds a attached-txt-file node to the file node' do
          expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/attached-txt-file")).to have(1).item
        end

        it 'adds attached file to zip' do
          expect(zip_files[file.full_file_name]).not_to be nil
        end
      end
    end

    context 'when task has a regular file' do
      let(:files) { [file] }
      let(:file) { build(:task_file, :exportable, content: 'foobar') }

      it_behaves_like 'task node with file'

      context 'when file has an attachment' do
        let(:file) { build(:task_file, :exportable, :with_attachment) }

        it 'adds a embedded-bin-file node to the file node' do
          expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/embedded-bin-file")).to have(1).item
        end
      end
    end

    context 'when task has a model-solution' do
      let(:model_solutions) { [model_solution] }
      let(:model_solution) { build(:model_solution, :with_content, files: ms_files, xml_id: 'ms-1') }
      let(:ms_files) { [ms_file] }
      let(:ms_file) { build(:task_file, :exportable) }

      it 'adds id attribute to model-solution node' do
        expect(xml.xpath('/task/model-solutions/model-solution').attribute('id').value).to eql model_solution.xml_id.to_s
      end

      it 'adds correct refid attribute to fileref' do
        expect(
          xml.xpath('/task/model-solutions/model-solution/filerefs/fileref').attribute('refid').value
        ).to eql xml.xpath('/task/files/file').attribute('id').value
      end

      it 'adds description attribute to model-solution' do
        expect(xml.xpath('/task/model-solutions/model-solution/description').text).to eql model_solution.description
      end

      it 'adds internal-description attribute to model-solution' do
        expect(xml.xpath('/task/model-solutions/model-solution/internal-description').text).to eql model_solution.internal_description
      end

      it 'adds correct used-by-grader attribute to referenced file node' do
        expect(xml.xpath('/task/files/file').attribute('used-by-grader').value).to eql ms_file.used_by_grader.to_s
      end

      it 'adds correct usage-by-lms attribute to referenced file node' do
        expect(xml.xpath('/task/files/file').attribute('usage-by-lms').value).to eql ms_file.usage_by_lms
      end

      it 'adds correct visible attribute to referenced file node' do
        expect(xml.xpath('/task/files/file').attribute('visible').value).to eql ms_file.visible
      end

      it 'adds correct role to internal-description of referenced file node' do
        expect(xml.xpath('/task/files/file/internal-description').text).to eql ms_file.internal_description
      end

      context 'when task has model-solution with multiple files' do
        let(:ms_files) { [ms_file, build(:task_file, :exportable)] }

        it 'adds two filerefs to model-solution node' do
          expect(xml.xpath('/task/model-solutions/model-solution/filerefs/fileref')).to have(2).items
        end
      end

      context 'when task has multiple model-solutions' do
        let(:model_solutions) { [model_solution, build(:model_solution, files: [build(:task_file, :exportable)], xml_id: 'ms-2')] }

        it 'adds two model-solution to task' do
          expect(xml.xpath('/task/model-solutions/model-solution')).to have(2).items
        end
      end
    end

    context 'when task has a test' do
      let(:tests) { [test] }
      let(:test) { build(:test, meta_data: test_meta_data) }
      let(:test_meta_data) {}

      it 'adds test node to tests node' do
        expect(xml.xpath('/task/tests/test')).to have(1).item
      end

      it 'adds id attribute to tests node' do
        expect(xml.xpath('/task/tests/test').attribute('id').value).to eql test.xml_id.to_s
      end

      it 'adds correct title node to test node' do
        expect(xml.xpath('/task/tests/test/title').text).to eql test.title
      end

      it 'adds fileref node' do
        expect(xml.xpath('/task/tests/test/test-configuration/filerefs/fileref')).to be_empty
      end

      context 'when test has a file' do
        let(:test) { build(:test, files: test_files) }
        let(:test_files) { [test_file] }
        let(:test_file) { build(:task_file, :exportable) }

        it 'adds test node to tests node' do
          expect(xml.xpath('/task/tests/test')).to have(1).item
        end
      end

      context 'when test has meta_data' do
        let(:test_meta_data) { {CodeOcean: {meta: 'data', nest: {even: {deeper: 'foobar'}}}} }
        let(:meta_data_path) { '/xmlns:task/xmlns:tests/xmlns:test/xmlns:test-configuration/xmlns:test-meta-data' }

        it 'adds meta_data node to task node' do
          expect(xml_with_namespaces.xpath("#{meta_data_path}/CodeOcean:meta").text).to eql 'data'
        end

        it 'adds nested meta_data node to task node' do
          expect(xml_with_namespaces.xpath("#{meta_data_path}/CodeOcean:nest/CodeOcean:even/CodeOcean:deeper").text).to eql 'foobar'
        end
      end
    end

    context 'when task has multiple tests' do
      let(:tests) { build_list(:test, 2) }

      it 'adds test node to tests node' do
        expect(xml.xpath('/task/tests/test')).to have(2).item
      end
    end
  end
end
