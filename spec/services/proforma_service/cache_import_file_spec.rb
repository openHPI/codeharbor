# frozen_string_literal: true

require 'rails_helper'

describe ProformaService::CacheImportFile do
  describe '.new' do
    subject(:cache_import_file) { described_class.new(user:, zip_file:) }

    let(:user) { build(:user) }
    let(:zip_file) { fixture_file_upload('proforma_import/testfile.zip', 'application/zip') }

    it 'assigns user' do
      expect(cache_import_file.instance_variable_get(:@user)).to be user
    end

    it 'assigns zip_file' do
      expect(cache_import_file.instance_variable_get(:@zip_file)).to be zip_file
    end
  end

  describe '#execute' do
    subject(:cache_import_file) { described_class.call(user:, zip_file:) }

    let(:user) { build(:user) }
    let(:zip_file) { fixture_file_upload('proforma_import/testfile.zip', 'application/zip') }

    it 'creates an ImportFileCache' do
      expect { cache_import_file }.to change(ImportFileCache, :count).by(1)
    end

    it 'returns a hash with data for one task' do
      expect(cache_import_file.values).to have(1).item
    end

    it 'returns a hash with the correct values' do
      expect(cache_import_file.values).to include(include(task_uuid: 'e9c562d8-43fc-4714-9848-6a21e38ef468', exists: false,
        import_id: be_an(Integer), path: 'testfile.zip', updatable: false))
    end

    it 'saves the data-hash in ImportFileCache' do
      cache_import_file
      expect(ImportFileCache.last.data.values).to include(include('task_uuid' => 'e9c562d8-43fc-4714-9848-6a21e38ef468',
        'exists' => false, 'import_id' => ImportFileCache.last.id,
        'path' => 'testfile.zip', 'updatable' => false))
    end

    context 'when an task with the uuid exists' do
      before { create(:task, uuid: 'e9c562d8-43fc-4714-9848-6a21e38ef468', user: task_user) }

      context 'when the user owns the task' do
        let(:task_user) { user }

        it 'returns a hash with the correct values' do
          expect(cache_import_file.values).to include(include(exists: true, updatable: true))
        end
      end

      context 'when the user does not own the task' do
        let(:task_user) { build(:user) }

        it 'returns a hash with the correct values' do
          expect(cache_import_file.values).to include(include(exists: true, updatable: false))
        end
      end
    end

    context 'when a file with three tasks is uploaded' do
      let(:zip_file) { fixture_file_upload('proforma_import/testfile_multi.zip', 'application/zip') }

      it 'creates only one ImportFileCache' do
        expect { cache_import_file }.to change(ImportFileCache, :count).by(1)
      end

      it 'returns a hash with data for three tasks' do
        expect(cache_import_file.values).to have(3).items
      end
    end

    context 'when a file with 100 tasks is uploaded' do
      before do
        allow(ProformaService::ConvertZipToProformaTasks).to receive(:call)
          .and_return(Array.new(100) {|i| {path: "zip#{i}.zip", uuid: SecureRandom.uuid} })
      end

      it 'creates only one ImportFileCache' do
        expect { cache_import_file }.to change(ImportFileCache, :count).by(1)
      end

      it 'returns a hash with data for 100 tasks' do
        expect(cache_import_file.values).to have(100).items
      end
    end
  end
end
