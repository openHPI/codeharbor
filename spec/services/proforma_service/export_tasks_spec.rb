# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ExportTasks do
  describe '.new' do
    subject(:export_service) { described_class.new(tasks:, options:) }

    let(:options) { {version: proforma_version} }
    let(:proforma_version) { '2.1' }
    let(:tasks) { build_list(:task, 2) }

    it 'assigns task' do
      expect(export_service.instance_variable_get(:@tasks)).to be tasks
    end
  end

  describe '#execute' do
    subject(:export_service) { described_class.call(tasks:, options:) }

    let(:options) { {version: nil} }
    let(:tasks) { create_list(:task, 2) }
    let(:user) { create(:user) }
    let(:zip_files) do
      {}.tap do |hash|
        Zip::InputStream.open(export_service) do |io|
          while (entry = io.get_next_entry)
            tempfile = Tempfile.new('proforma-test-tmp')
            tempfile.write(entry.get_input_stream.read.force_encoding('UTF-8'))
            tempfile.rewind
            hash[entry.name] = tempfile
          end
        end
      end
    end
    let(:doc) { Nokogiri::XML(zip_files['task.xml'], &:noblanks) }
    let(:xml) { doc.remove_namespaces! }
    let(:imported_tasks) { zip_files.transform_values! {|zip_file| ProformaService::Import.call(zip: zip_file, user:) } }

    it 'creates a zip-file with two files' do
      expect(zip_files.count).to be 2
    end

    it 'creates a zip-file of two importable zip-files' do
      expect(imported_tasks.values).to all be_an(Task)
    end

    it 'creates a zip-file of two importable zip-files which contain valid tasks' do
      expect(imported_tasks.values).to all be_valid
    end

    it 'names the zipped files correctly' do
      expect(zip_files.keys).to match_array(tasks.map {|e| "task_#{e.id}-#{e.title.underscore.gsub(/[^0-9A-Za-z.-]/, '_')}.zip" })
    end

    context 'when 10 tasks are supplied' do
      let(:tasks) { create_list(:task, 10) }

      it 'creates a zip-file with two files' do
        expect(zip_files.count).to be 10
      end
    end

    context 'when proforma_version is 2.0' do
      let(:proforma_version) { '2.0' }

      it 'calls ExportTask with correct arguments' do
        expect(ProformaService::ExportTask).to receive(:call).twice.and_call_original
        export_service
      end
    end
  end
end
