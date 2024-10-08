# frozen_string_literal: true

RSpec.shared_examples 'transfer multiple entities' do |model|
  def entities(model)
    model.to_s == 'task_file' ? 'files' : model.to_s.pluralize
  end

  let(:entities) { model == TaskFile ? :files_collection : model.name.underscore.pluralize }
  let(:model_factory) { model.name.underscore.to_sym }

  subject(:transfer_multiple) { task.transfer_multiple_entities(task.send(entities), other_task.send(entities)) }

  let(:task) { create(:task) }
  let(:other_task) { create(:task, parent_uuid: task.uuid) }
  let(:instance1) { build(model_factory, internal_description: 'Instance 1') }
  let(:instance2) { build(model_factory, internal_description: 'Instance 2') }
  let(:instance3) { build(model_factory, internal_description: 'Instance 3') }

  context 'when the entity only exists in the original task' do
    before do
      instance3.parent = instance1
      task.send(:"#{entities}=", [instance1, instance2])
      other_task.send(:"#{entities}=", [instance3])
    end

    it 'deletes the other instance' do
      transfer_multiple
      expect(task.send(entities)).to contain_exactly(instance1)
    end
  end

  context 'when the entity exists in both tasks' do
    let(:instance4) { build(model_factory, internal_description: 'Instance 4') }

    before do
      instance2.parent = instance1
      instance4.parent = instance3
      task.send(:"#{entities}=", [instance1, instance3])
      other_task.send(:"#{entities}=", [instance2, instance4])
    end

    it 'contains the correct instances' do
      transfer_multiple
      expect(task.send(entities)).to contain_exactly(instance1, instance3)
    end

    it 'contains the modified version' do
      transfer_multiple
      expect(task.send(entities).find {|i| i.internal_description == 'Instance 2' }).to be_present
      expect(task.send(entities).find {|i| i.internal_description == 'Instance 4' }).to be_present
    end
  end

  context 'when the entity only exists in the other task' do
    before do
      instance3.parent = instance1
      task.send(:"#{entities}=", [instance1])
      other_task.send(:"#{entities}=", [instance2, instance3])
    end

    it 'contains the correct instances' do
      transfer_multiple
      expect(task.send(entities).find {|i| i.internal_description == 'Instance 2' }).to be_present
      expect(task.send(entities).find {|i| i.internal_description == 'Instance 3' }).to be_present
    end
  end
end
