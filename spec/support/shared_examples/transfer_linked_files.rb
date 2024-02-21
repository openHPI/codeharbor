# frozen_string_literal: true

RSpec.shared_examples 'transfer linked files' do |model|
  subject(:transfer_linked_files) { instance.transfer_linked_files(other_instance) }

  let(:instance) { create(model, files: []) }
  let(:other_instance) { create(model, files: []) }
  let(:file1) { build(:task_file, :exportable, name: 'File1') }
  let(:file2) { build(:task_file, :exportable, name: 'File2') }
  let(:file3) { build(:task_file, :exportable, name: 'File3') }

  context 'when the file only exists in the original instance' do
    before do
      file2.parent = file1
      instance.files = [file1, file3]
      other_instance.files = [file2]
    end

    it 'deletes the other file' do
      transfer_linked_files
      expect(instance.reload.files).to contain_exactly(file1)
    end
  end

  context 'when the file only exists in the other instance' do
    before do
      file2.parent = file1
      instance.files = [file1]
      other_instance.files = [file2, file3]
    end

    it 'contains the correct files' do
      transfer_linked_files
      expect(instance.files.count).to eq(2)
      expect(instance.files).to include(file1)
      expect(instance.files.find {|f| f.name == 'File3' }).to be_present
    end
  end

  context 'when the file exists in both instances' do
    let(:file4) { build(:task_file, :exportable, name: 'File4') }

    before do
      file2.parent = file1
      file4.parent = file3
      instance.files = [file1, file3]
      other_instance.files = [file2, file4]
    end

    it 'contains the correct files' do
      transfer_linked_files
      expect(instance.files).to contain_exactly(file1, file3)
    end

    it 'contains the modified version' do
      transfer_linked_files
      expect(instance.files.find {|f| f.name == 'File2' }).to be_present
      expect(instance.files.find {|f| f.name == 'File4' }).to be_present
    end
  end
end
