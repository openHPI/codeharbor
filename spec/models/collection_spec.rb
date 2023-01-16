# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:collection_user) { create(:user) }
    let(:collection) { create(:collection, users:) }
    let(:users) { [collection_user] }

    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }

    it { is_expected.not_to be_able_to(:show, collection) }
    it { is_expected.not_to be_able_to(:update, collection) }
    it { is_expected.not_to be_able_to(:leave, collection) }
    it { is_expected.not_to be_able_to(:remove_exercise, collection) }
    it { is_expected.not_to be_able_to(:remove_all, collection) }
    it { is_expected.not_to be_able_to(:push_collection, collection) }
    it { is_expected.not_to be_able_to(:download_all, collection) }
    it { is_expected.not_to be_able_to(:share, collection) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }

      it { is_expected.not_to be_able_to(:show, collection) }
      it { is_expected.not_to be_able_to(:update, collection) }
      it { is_expected.not_to be_able_to(:leave, collection) }
      it { is_expected.not_to be_able_to(:remove_exercise, collection) }
      it { is_expected.not_to be_able_to(:remove_all, collection) }
      it { is_expected.not_to be_able_to(:push_collection, collection) }
      it { is_expected.not_to be_able_to(:download_all, collection) }
      it { is_expected.not_to be_able_to(:share, collection) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, collection) }
        it { is_expected.not_to be_able_to(:leave, collection) }
      end

      context 'when collection is from user' do
        let(:collection_user) { user }

        it { is_expected.not_to be_able_to(:manage, described_class) }

        it { is_expected.not_to be_able_to(:manage, collection) }
        it { is_expected.to be_able_to(:show, collection) }
        it { is_expected.to be_able_to(:update, collection) }
        it { is_expected.to be_able_to(:leave, collection) }
        it { is_expected.to be_able_to(:remove_exercise, collection) }
        it { is_expected.to be_able_to(:remove_all, collection) }
        it { is_expected.to be_able_to(:push_collection, collection) }
        it { is_expected.to be_able_to(:download_all, collection) }
        it { is_expected.to be_able_to(:share, collection) }
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:users) }
  end

  describe '#add_exercise', pending: 'collections are currently broken' do
    subject(:add_exercise) { collection.add_exercise(exercise) }

    let(:user) { create(:user) }
    let(:exercise) { create(:simple_exercise) }

    context 'when exercise is not in collection' do
      let(:collection) { create(:collection, users: [user], exercises: []) }

      it { is_expected.to be_truthy }

      it 'adds exercise' do
        expect { add_exercise }.to change(collection.exercises, :count).by(1)
      end
    end

    context 'when exercise is in collection' do
      let(:collection) { create(:collection, users: [user], exercises: [exercise]) }

      it { is_expected.to be_falsey }

      it 'does not add when in collection already' do
        expect { add_exercise }.not_to change(collection.exercises, :count)
      end
    end
  end

  describe '#remove_exercise', pending: 'collections are currently broken' do
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

  describe '#destroy', pending: 'collections are currently broken' do
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
      expect(build_stubbed(:collection)).to be_valid
    end

    it 'requires title' do
      expect(build_stubbed(:collection, title: '')).not_to be_valid
    end
  end
end
