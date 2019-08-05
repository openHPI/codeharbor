# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  describe '#add_exercise' do
    subject(:add_exercise) { collection.add_exercise(exercise) }

    let(:user) { create(:user) }
    let(:exercise) { create(:simple_exercise) }

    context 'when exercise not in collection' do
      let(:collection) { create(:collection, users: [user], exercises: []) }

      it { is_expected.to be_truthy }

      it 'adds exercise' do
        expect { add_exercise }.to change(collection.exercises, :count).by(1)
      end
    end

    context 'when exercise not in collection' do
      let(:collection) { create(:collection, users: [user], exercises: [exercise]) }

      it { is_expected.to be_falsey }

      it 'does not add when in collection already' do
        expect { add_exercise }.not_to change(collection.exercises, :count)
      end
    end
  end

  describe '#remove_exercise' do
    subject(:remove_exercise) { collection.remove_exercise(exercise) }

    let(:user) { create(:user) }
    let(:collection) { create(:collection, users: [user], exercises: [exercise]) }
    let!(:exercise) { create(:simple_exercise) }

    it { is_expected.to be_truthy }

    it 'does not delete exercise' do
      expect { remove_exercise }.not_to change(Exercise, :count)
    end

    it 'removes exercise from group' do
      expect { remove_exercise }.to change(collection.exercises, :count).by(-1)
    end
  end

  describe '#destroy' do
    subject(:destroy) { collection.destroy }

    let(:user) { create(:user) }
    let!(:collection) { create(:collection, users: [user], exercises: create_list(:simple_exercise, 2)) }

    it { is_expected.to be_truthy }

    it 'deletes collection' do
      expect { destroy }.to change(described_class, :count).by(-1)
    end

    it 'does not delete exercises' do
      expect { destroy }.not_to change(Exercise, :count)
    end
  end

  # Not really testing any functionality here
  describe 'factories' do
    it 'has valid factory' do
      expect(FactoryBot.build_stubbed(:collection)).to be_valid
    end

    it 'requires title' do
      expect(FactoryBot.build_stubbed(:collection, title: '')).not_to be_valid
    end
  end
end
