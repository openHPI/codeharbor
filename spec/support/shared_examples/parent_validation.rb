# frozen_string_literal: true

# frozen_string_literals: true

RSpec.shared_examples 'parent validation with parent_id' do |model|
  let(:task) { create(:task) }
  let(:p_uuid) { nil }
  let(:other_task) { create(:task, parent_uuid: p_uuid) }
  let(:original_instance) { create(model, task:) }
  let(:other_instance) { create(model, task: other_task) }

  context 'when it has no parent' do
    it 'is valid' do
      expect(original_instance).to be_valid
    end
  end

  context 'when it has a parent' do
    context 'when the parent_id is invalid' do
      before do
        other_instance.parent_id = -1
      end

      it 'is not valid' do
        expect(other_instance).not_to be_valid
      end
    end

    context 'when the parent_id is valid' do
      before do
        other_instance.parent = original_instance
      end

      context 'when the task has a valid parent' do
        let(:p_uuid) { task.uuid }

        it 'is valid' do
          expect(other_instance).to be_valid
        end
      end

      context 'when the task has an invalid parent' do
        it 'is not valid' do
          expect(other_instance).not_to be_valid
        end
      end
    end
  end
end
