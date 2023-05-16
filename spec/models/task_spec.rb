# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:task_user) { create(:user) }
    let(:group_user) { create(:user) }
    let(:access_level) { 'private' }
    let!(:group) { create(:group) }
    let(:task) { create(:task, user: task_user, access_level:, groups: [group]) }
    let(:authors) { [] }
    let(:role) { :confirmed_member }
    before do
      group.add(group_user, role:)
      group.reload
    end


    it { is_expected.not_to be_able_to(:index, described_class) }
    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:import_start, described_class) }
    it { is_expected.not_to be_able_to(:import_confirm, described_class) }
    it { is_expected.not_to be_able_to(:show, task) }
    it { is_expected.not_to be_able_to(:update, task) }
    it { is_expected.not_to be_able_to(:destroy, task) }
    it { is_expected.not_to be_able_to(:download, task) }
    it { is_expected.not_to be_able_to(:add_to_collection, task) }
    it { is_expected.not_to be_able_to(:export_external_start, task) }
    it { is_expected.not_to be_able_to(:export_external_check, task) }
    it { is_expected.not_to be_able_to(:export_external_confirm, task) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:index, described_class) }
      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:import_start, described_class) }
      it { is_expected.to be_able_to(:import_confirm, described_class) }

      it { is_expected.not_to be_able_to(:show, task) }
      it { is_expected.not_to be_able_to(:download, task) }
      it { is_expected.not_to be_able_to(:add_to_collection, task) }

      it { is_expected.not_to be_able_to(:update, task) }
      it { is_expected.not_to be_able_to(:destroy, task) }

      it { is_expected.not_to be_able_to(:export_external_start, task) }
      it { is_expected.not_to be_able_to(:export_external_check, task) }
      it { is_expected.not_to be_able_to(:export_external_confirm, task) }

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
        it { is_expected.to be_able_to(:add_to_collection, task) }

        it { is_expected.to be_able_to(:export_external_start, task) }
        it { is_expected.to be_able_to(:export_external_check, task) }
        it { is_expected.to be_able_to(:export_external_confirm, task) }

        it { is_expected.to be_able_to(:update, task) }
        it { is_expected.to be_able_to(:destroy, task) }
      end

      context 'when task has access_level "public"' do
        let(:task_user) { create(:user) }
        let(:access_level) { 'public' }

        it { is_expected.to be_able_to(:show, task) }
        it { is_expected.to be_able_to(:export, task) }
        it { is_expected.to be_able_to(:download, task) }
        it { is_expected.to be_able_to(:add_to_collection, task) }

        it { is_expected.not_to be_able_to(:update, task) }
        it { is_expected.not_to be_able_to(:destroy, task) }
      end

      context 'when task is "private" and in same group' do
        let(:user) { group_user }
        let(:access_level) { 'private' }

        it { is_expected.to be_able_to(:update, task) }
        it { is_expected.not_to be_able_to(:destroy, task) }

        context 'when user is group-admin' do
          let(:role) { 'admin' }

          it { is_expected.to be_able_to(:destroy, task) }
        end
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
    it { is_expected.to belong_to(:user) }

    it { is_expected.to allow_value('de-DE').for(:language) }
    it { is_expected.to allow_value('en').for(:language) }
    it { is_expected.not_to allow_value('verylonglanguagename').for(:language) }
    it { is_expected.not_to allow_value('$pecial').for(:language) }
  end

  describe '.visibility' do
    subject { described_class.visibility(visibility, user) }

    let(:visibility) { 'owner' }
    let(:user) { create(:user) }
    let(:task_user) { user }
    let!(:task) { create(:task, user: task_user, access_level: 'public') }

    it { is_expected.to contain_exactly task }

    context 'when task belongs to different user' do
      let(:task_user) { create(:user) }

      it { is_expected.to be_empty }
    end

    context 'when visibility is "public"' do
      let(:visibility) { 'public' }

      it { is_expected.to contain_exactly task }

      context 'when task belongs to different user' do
        let(:task_user) { create(:user) }

        it { is_expected.to contain_exactly task }
      end
    end
  end

  describe '.created_before_days' do
    subject { described_class.created_before_days(days) }

    let(:days) { 0 }
    let!(:new_task) { create(:task, created_at: 1.week.ago) }
    let!(:old_task) { create(:task, created_at: 4.weeks.ago) }

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

  describe '#duplicate' do
    subject(:duplicate) { task.duplicate }

    let(:task) { create(:task, files:, tests:, model_solutions:) }
    let(:files) { build_list(:task_file, 2, :exportable) }
    let(:tests) { build_list(:test, 2) }
    let(:model_solutions) { build_list(:model_solution, 2) }

    it 'creates a new task' do
      expect(duplicate).not_to be task
    end

    it 'has no uuid' do
      expect(duplicate.uuid).to be_nil
    end

    it 'has the same attributes' do
      expect(duplicate).to be_an_equal_task_as task
    end

    it 'creates new files' do
      expect(duplicate.files).not_to match_array task.files
    end

    it 'creates new files with the same attributes' do
      expect(duplicate.files).to match_array(task.files.map do |file|
                                               have_attributes(file.attributes.except('created_at', 'updated_at', 'id', 'fileable_id'))
                                             end)
    end

    it 'creates new tests' do
      expect(duplicate.tests).not_to match_array task.tests
    end

    it 'creates new tests with the same attributes' do
      expect(duplicate.tests).to match_array(task.tests.map do |file|
                                               have_attributes(file.attributes.except('created_at', 'updated_at', 'id', 'task_id'))
                                             end)
    end

    it 'creates new model_solutions' do
      expect(duplicate.tests).not_to match_array task.model_solutions
    end

    it 'creates new model_solutions with the same attributes' do
      expect(duplicate.model_solutions).to match_array(task.model_solutions.map do |file|
                                                         have_attributes(file.attributes.except('created_at', 'updated_at', 'id',
                                                           'task_id'))
                                                       end)
    end
  end

  describe '#destroy' do
    subject(:destroy) { task.destroy }

    let(:group) { create(:group) }
    let(:collection) { create(:collection, tasks: [task]) }
    let!(:task) { create(:task, groups: [group]) }

    it 'removes group from task' do
      expect(group.tasks).not_to be_empty
      destroy
      expect(group.reload.tasks).to be_empty
    end

    it 'removes task from collection' do
      expect(collection.tasks).not_to be_empty
      destroy
      expect(collection.reload.tasks).to be_empty
    end
  end
end
