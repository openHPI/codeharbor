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
    it { is_expected.not_to be_able_to(:import_start, described_class) }
    it { is_expected.not_to be_able_to(:import_confirm, described_class) }
    it { is_expected.not_to be_able_to(:show, task) }
    it { is_expected.not_to be_able_to(:update, task) }
    it { is_expected.not_to be_able_to(:destroy, task) }
    it { is_expected.not_to be_able_to(:download, task) }
    it { is_expected.not_to be_able_to(:export, task) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:index, described_class) }
      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:import_start, described_class) }
      it { is_expected.to be_able_to(:import_confirm, described_class) }

      it { is_expected.not_to be_able_to(:show, task) }
      it { is_expected.not_to be_able_to(:download, task) }
      it { is_expected.not_to be_able_to(:export, task) }

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
        it { is_expected.to be_able_to(:download, task) }
        it { is_expected.to be_able_to(:export, task) }

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

  describe '.visibility' do
    subject { described_class.visibility(visibility, user) }

    let(:visibility) { 'owner' }
    let(:user) { create(:user) }
    let(:task_user) { user }
    let!(:task) { create(:task, user: task_user) }

    it { is_expected.to contain_exactly task }

    context 'when task belongs to different user' do
      let(:task_user) { create(:user) }

      it { is_expected.to be_empty }
    end

    context 'when visibility is "public"' do
      let(:visibility) { 'public' }

      it { is_expected.to be_empty }

      context 'when task belongs to different user' do
        let(:task_user) { create(:user) }

        it { is_expected.to contain_exactly task }
      end
    end
  end

  describe '.created_before_days' do
    subject { described_class.created_before_days(days) }

    let(:days) { 0 }
    let!(:new_task) { create(:task, created_at: Time.zone.now - 1.week) }
    let!(:old_task) { create(:task, created_at: Time.zone.now - 4.weeks) }

    it { is_expected.to include new_task, old_task }

    context 'when task days is 1' do
      let(:days) { 1 }

      it { is_expected.to be_empty }
    end

    context 'when task days is 7' do
      let(:days) { 7 }

      it { is_expected.to contain_exactly new_task }
    end

    context 'when task days is 30' do
      let(:days) { 30 }

      it { is_expected.to include new_task, old_task }
    end
  end
end
