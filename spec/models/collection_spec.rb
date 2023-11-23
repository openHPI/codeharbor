# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:users) }
    it { expect(build(:collection, title: 'some title', description: '')).to be_valid }
    it { expect(build(:collection, title: 'some title', description: 'X' * 4000)).to be_valid }
    it { expect(build(:collection, title: 'some title', description: 'X' * 4001)).not_to be_valid }
  end

  describe '#add_task' do
    subject(:add_task) { collection.add_task(task) }

    let(:user) { create(:user) }
    let(:task) { create(:task) }

    context 'when task is not in collection' do
      let(:collection) { create(:collection, users: [user], tasks: []) }

      it { is_expected.to be_truthy }

      it 'adds task' do
        expect { add_task }.to change(collection.tasks, :count).by(1)
      end
    end

    context 'when task is in collection' do
      let(:collection) { create(:collection, users: [user], tasks: [task]) }

      it { is_expected.to be_falsey }

      it 'does not add when in collection already' do
        expect { add_task }.not_to change(collection.tasks, :count)
      end
    end
  end

  describe '#remove_task' do
    subject(:remove_task) { collection.remove_task(task) }

    let(:user) { create(:user) }
    let(:collection) { create(:collection, users: [user], tasks: [task]) }
    let!(:task) { create(:task) }

    it { is_expected.to be_truthy }

    it 'does not delete task' do
      expect { remove_task }.not_to change(Task, :count)
    end

    it 'removes task from group' do
      expect { remove_task }.to change(collection.tasks, :count).by(-1)
    end
  end

  describe '#remove_all' do
    subject(:remove_all) { collection.remove_all }

    let(:user) { create(:user) }
    let(:number_of_tasks) { 2 }
    let!(:collection) { create(:collection, users: [user], tasks: create_list(:task, number_of_tasks, user:)) }

    it { is_expected.to be_truthy }

    it 'does not delete any task' do
      expect { remove_all }.not_to change(Task, :count)
    end

    it 'removes all tasks from group' do
      expect { remove_all }.to change(collection.tasks, :count).by(-number_of_tasks)
    end
  end

  describe '#destroy' do
    subject(:destroy) { collection.destroy }

    let(:user) { create(:user) }
    let!(:collection) { create(:collection, users: [user], tasks: create_list(:task, 2)) }

    it { is_expected.to be_truthy }

    it 'deletes collection' do
      expect { destroy }.to change(described_class, :count).by(-1)
    end

    it 'does not delete tasks' do
      expect { destroy }.not_to change(Task, :count)
    end
  end

  # Not really testing any functionality here
  describe 'factories' do
    it 'has valid factory' do
      expect(build_stubbed(:collection)).to be_valid
    end

    it 'requires title' do
      expect(build_stubbed(:collection, title: '')).not_to be_valid
    end
  end
end
