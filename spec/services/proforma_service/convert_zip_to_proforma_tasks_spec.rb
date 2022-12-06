# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ConvertZipToProformaTasks do
  describe '.new' do
    subject(:convert_zip_to_tasks) { described_class.new(zip_file:) }

    let(:zip_file) { fixture_file_upload('proforma_import/testfile.zip', 'application/zip') }

    it 'assigns zip_file' do
      expect(convert_zip_to_tasks.instance_variable_get(:@zip_file)).to be zip_file
    end

    it 'assigns depth' do
      expect(convert_zip_to_tasks.instance_variable_get(:@depth)).to be 1
    end

    it 'assigns path' do
      expect(convert_zip_to_tasks.instance_variable_get(:@path)).to eql 'testfile.zip'
    end

    context 'with all arguments' do
      subject(:convert_zip_to_tasks) { described_class.new(zip_file:, depth:, path:) }

      let(:depth) { 2 }
      let(:path) { 'path' }

      it 'assigns zip_file' do
        expect(convert_zip_to_tasks.instance_variable_get(:@zip_file)).to be zip_file
      end

      it 'assigns depth' do
        expect(convert_zip_to_tasks.instance_variable_get(:@depth)).to be 3
      end

      it 'assigns path' do
        expect(convert_zip_to_tasks.instance_variable_get(:@path)).to eql 'path'
      end

      context 'with depth of 6' do
        let(:depth) { 6 }

        it 'raises error' do
          expect { convert_zip_to_tasks }.to raise_error I18n.t('exercises.import_exercise.convert_zip.nested_too_deep')
        end
      end
    end
  end

  describe '#execute' do
    subject(:convert_zip_to_tasks) { described_class.call(zip_file:) }

    let(:zip_file) { fixture_file_upload('proforma_import/testfile.zip', 'application/zip') }
    let(:importer) { instance_double(Proforma::Importer, perform: importer_result) }
    let(:importer_result) { {task:, custom_namespaces: []} }
    let(:task) { instance_double(Proforma::Task, uuid: 'uuid') }

    before { allow(Proforma::Importer).to receive(:new).and_return(importer) }

    it 'returns an array with a hash for the task' do
      expect(convert_zip_to_tasks).to eql [{path: 'testfile.zip', uuid: 'uuid', task:}]
    end

    context 'when zip_file contains multiple zipped tasks' do
      let(:zip_file) { fixture_file_upload('proforma_import/testfile_multi.zip', 'application/zip') }

      it 'returns an array with a hash for the task' do
        expect(convert_zip_to_tasks).to match_array [
          {path: 'testfile_multi.zip/task_24-short_hello_world.zip', uuid: 'uuid', task:},
          {path: 'testfile_multi.zip/task_1-haha_world__123456.zip', uuid: 'uuid', task:},
          {path: 'testfile_multi.zip/task_2-hallo_welt.zip', uuid: 'uuid', task:}
        ]
      end
    end
  end
end
