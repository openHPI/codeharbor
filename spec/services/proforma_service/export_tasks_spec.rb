# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ExportTasks do
  describe '.new' do
    subject(:export_service) { described_class.new(exercises: exercises) }

    let(:exercises) { build_list(:exercise, 2) }

    it 'assigns exercise' do
      expect(export_service.instance_variable_get(:@exercises)).to be exercises
    end
  end

  describe '#execute' do
    subject(:export_service) { described_class.call(exercises: exercises) }

    let(:exercises) { create_list(:exercise, 2) }
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
    let(:imported_exercises) { zip_files.transform_values! { |zip_file| ProformaService::Import.call(zip: zip_file, user: user) } }

    it 'creates a zip-file with two files' do
      expect(zip_files.count).to be 2
    end

    it 'creates a zip-file of two importable zip-files' do
      expect(imported_exercises.values).to all be_an(Exercise)
    end

    it 'creates a zip-file of two importable zip-files which contain valid exercises' do
      expect(imported_exercises.values).to all be_valid
    end

    it 'names the zipped files correctly' do
      expect(zip_files.keys).to match_array(exercises.map { |e| "task_#{e.id}-#{e.title.underscore.gsub(/[^0-9A-Za-z.\-]/, '_')}.zip" })
    end

    context 'when 10 exercises are supplied' do
      let(:exercises) { create_list(:exercise, 10) }

      it 'creates a zip-file with two files' do
        expect(zip_files.count).to be 10
      end
    end
  end
end
