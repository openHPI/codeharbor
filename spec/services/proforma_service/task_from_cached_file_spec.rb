# frozen_string_literal: true

require 'rails_helper'

describe ProformaService::TaskFromCachedFile do
  describe '.new' do
    subject(:task_from_cached_file) { described_class.new(import_id: import_id, subfile_id: subfile_id, import_type: import_type) }

    let(:import_id) { 1 }
    let(:subfile_id) { 2 }
    let(:import_type) { 'import' }

    it 'assigns import_id' do
      expect(task_from_cached_file.instance_variable_get(:@import_id)).to be import_id
    end

    it 'assigns subfile_id' do
      expect(task_from_cached_file.instance_variable_get(:@subfile_id)).to be subfile_id
    end

    it 'assigns import_type' do
      expect(task_from_cached_file.instance_variable_get(:@import_type)).to be import_type
    end
  end

  describe '#execute' do
    subject(:task_from_cached_file) do
      described_class.call(import_id: import_file_cache.id, subfile_id: subfile_id, import_type: import_type)
    end

    let!(:data) { ProformaService::CacheImportFile.call(user: user, zip_file: zip_file) }
    let(:user) { build(:user) }
    let(:zip_file) { fixture_file_upload('files/proforma_import/testfile.zip', 'application/zip') }
    let(:subfile_id) { data.first[0] }
    let(:import_file_cache) { ImportFileCache.find(data[subfile_id][:import_id]) }
    let(:import_type) { 'import' }

    it 'returns a task' do
      expect(task_from_cached_file).to be_a Proforma::Task
    end

    # rubocop:disable RSpec/ExampleLength
    it 'sets the attributes of task' do
      expect(task_from_cached_file).to have_attributes(
        description: be_present,
        internal_description: be_present,
        language: be_present,
        model_solutions: be_present,
        proglang: be_present,
        title: be_present,
        uuid: be_present
      )
    end

    context 'when import_type is create_new' do
      let(:import_type) { 'create_new' }

      it 'sets the attributes of task but uuid stays nil' do
        expect(task_from_cached_file).to have_attributes(
          description: be_present,
          internal_description: be_present,
          language: be_present,
          model_solutions: be_present,
          proglang: be_present,
          title: be_present,
          uuid: be_nil
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
