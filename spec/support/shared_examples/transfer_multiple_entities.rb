# frozen_string_literal: true

RSpec.shared_examples 'transfer multiple entities' do |model|
  subject(:transfer_multiple) { task.transfer_multiple_entities(task.send(model.to_s.pluralize), other_task.send(model.to_s.pluralize), model.to_s) }

  let(:task) { create(:task) }
  let(:other_task) { create(:task, parent_uuid: task.uuid) }
  let(:instance1) { build(model, internal_description: 'Instance 1') }
  let(:instance2) { build(model, internal_description: 'Instance 2') }
  let(:instance3) { build(model, internal_description: 'Instance 3') }

  context 'when the entity only exists in the original task' do
    before do
      instance3.parent = instance1
      task.send(:"#{model.to_s.pluralize}=", [instance1, instance2])
      other_task.send(model.to_s.pluralize) << instance3
    end

    it 'deletes the other instance' do
      transfer_multiple
      expect(task.send(model.to_s.pluralize)).to contain_exactly(instance1)
    end
  end

  context 'when the entity exists in both tasks' do
    let(:instance4) { build(model, internal_description: 'Instance 4') }

    before do
      instance2.parent = instance1
      instance4.parent = instance3
      task.send(:"#{model.to_s.pluralize}=", [instance1, instance3])
      other_task.send(:"#{model.to_s.pluralize}=", [instance2, instance4])
    end

    it 'contains the correct instances' do
      transfer_multiple
      expect(task.send(model.to_s.pluralize)).to contain_exactly(instance1, instance3)
    end

    it 'contains the modified version' do
      transfer_multiple
      expect(task.send(model.to_s.pluralize).find {|i| i.internal_description == 'Instance 2' }).to be_present
      expect(task.send(model.to_s.pluralize).find {|i| i.internal_description == 'Instance 4' }).to be_present
    end
  end

  context 'when the entity only exists in the other task' do
    before do
      instance3.parent = instance1
      task.send(:"#{model.to_s.pluralize}=", [instance1])
      other_task.send(:"#{model.to_s.pluralize}=", [instance2, instance3])
    end

    it 'contains the correct instances' do
      transfer_multiple
      expect(task.send(model.to_s.pluralize).find {|i| i.internal_description == 'Instance 2' }).to be_present
      expect(task.send(model.to_s.pluralize).find {|i| i.internal_description == 'Instance 3' }).to be_present
    end
  end
end
