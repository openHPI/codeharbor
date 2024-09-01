# frozen_string_literal: true

# The primary logic is already covered by 'transfer multiple entities' this is just used to test the recursive call for files
RSpec.shared_examples 'transfer files' do |model|
  def entities(model)
    model.name.underscore.pluralize.to_sym
  end

  let(:model_factory) { model.name.underscore.to_sym }

  subject(:transfer_files) { task.transfer_multiple_entities(task.send(entities(model)), other_task.send(entities(model))) }

  let(:task) { create(:task) }
  let(:other_task) { create(:task, parent_uuid: task.uuid) }
  let(:instance1) { build(model_factory, internal_description: 'Instance 1') }
  let(:instance2) { build(model_factory, internal_description: 'Instance 2') }

  context 'when the entity exists in both tasks' do
    let(:file1) { build(:task_file, name: 'File 1') }
    let(:file2) { build(:task_file, name: 'File 2') }
    let(:file3) { build(:task_file, name: 'File 3') }
    let(:file4) { build(:task_file, name: 'File 4') }
    before do
      file2.parent = file1
      instance2.parent = instance1
      instance1.files = [file1, file3]
      instance2.files = [file2, file4]
      task.send(:"#{entities(model)}=", [instance1])
      other_task.send(:"#{entities(model)}=", [instance2])
    end

    it 'contains the correct contents' do
      transfer_files
      expect(task.send(entities(model))).to contain_exactly(instance1)
      expect(instance1.files).to include(file1)
      expect(instance1.files.find {|f| f.name == 'File 2' }).to be_present
      expect(instance1.files.find {|f| f.name == 'File 4' }).to be_present
    end
  end
end
