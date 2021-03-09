# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:task_user) { create(:user) }
    let(:task) { create(:task, user: task_user) }
    let(:private?) { false }
    let(:authors) { [] }

    it { is_expected.not_to be_able_to(:index, described_class) }
    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:show, task) }
    it { is_expected.not_to be_able_to(:update, task) }
    it { is_expected.not_to be_able_to(:destroy, task) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:index, described_class) }
      it { is_expected.to be_able_to(:create, described_class) }

      it { is_expected.not_to be_able_to(:show, task) }

      it { is_expected.not_to be_able_to(:update, task) }
      it { is_expected.not_to be_able_to(:destroy, task) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, task) }
      end

      context 'when task is from user' do
        let(:task_user) { user }

        it { is_expected.not_to be_able_to(:manage, described_class) }
        it { is_expected.not_to be_able_to(:manage, task) }

        it { is_expected.to be_able_to(:show, task) }

        it { is_expected.to be_able_to(:update, task) }
        it { is_expected.to be_able_to(:destroy, task) }
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
    it { is_expected.to belong_to(:user) }
  end
end
