# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task do
  include ActiveJob::TestHelper

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

    let(:visibility) { :owner }
    let(:user) { create(:user) }
    let(:task_user) { user }
    let!(:task) { create(:task, user: task_user, access_level: :public) }

    it { is_expected.to contain_exactly task }

    context 'when task belongs to different user' do
      let(:task_user) { create(:user) }

      it { is_expected.to be_empty }
    end

    context 'when visibility is "public"' do
      let(:visibility) { :public }

      it { is_expected.to contain_exactly task }

      context 'when task belongs to different user' do
        let(:task_user) { create(:user) }

        it { is_expected.to contain_exactly task }
      end
    end

    context 'when visibility is "invalid"' do
      let(:visibility) { 'invalid' }

      it { is_expected.to contain_exactly task }
    end

    context 'when visibility is "group"' do
      let(:user) { create(:user) }
      let(:role) { :confirmed_member }
      let(:group_memberships) { [build(:group_membership, :with_admin), build(:group_membership, user:, role:)] }
      let(:groups) { create_list(:group, 1, group_memberships:) }
      let(:group_task) { create(:task, user: task_user, access_level: :public, groups:) }
      let(:visibility) { :group }

      it { is_expected.to contain_exactly group_task }
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

    let(:task) { create(:task, files:, tests:, model_solutions:, title: 'title', user: task_user, access_level: :public, groups:) }
    let(:files) { build_list(:task_file, 2, :exportable) }
    let(:tests) { build_list(:test, 2) }
    let(:model_solutions) { build_list(:model_solution, 2) }
    let(:task_user) { create(:user) }
    let(:groups) { create_list(:group, 1) }

    it 'creates a new task' do
      expect(duplicate).not_to be task
    end

    it 'has no uuid' do
      expect(duplicate.uuid).to be_nil
    end

    it 'has the correct parent_uuid' do
      expect(duplicate.parent_uuid).to eq task.uuid
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

    context 'when task is cleanly duplicated' do
      subject(:clean_duplicate) { task.clean_duplicate user }

      let(:user) { create(:user) }

      it 'has the current user' do
        expect(clean_duplicate.user).to be user
      end

      it 'is private' do
        expect(clean_duplicate.access_level).to eq(:private.to_s)
      end

      it 'is not part of a group' do
        expect(clean_duplicate.groups).to eq([])
      end

      it 'has a modified title' do
        expect(clean_duplicate.title).to eq('Copy of Task: title')
      end
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

    it 'enqueues an NbpSyncJob' do
      expect { destroy }.to have_enqueued_job(NbpSyncJob).with(task.uuid)
    end
  end

  describe '#update' do
    subject(:update) { task.update(new_attributes) }

    let!(:task) { create(:task, access_level:) }

    context 'when updating a public task' do
      let(:access_level) { :public }
      let(:new_attributes) { {title: 'some new title'} }

      it 'enqueues an NbpSyncJob' do
        expect { update }.to have_enqueued_job(NbpSyncJob).with(task.uuid)
      end

      context 'when updating the uuid' do
        let(:new_attributes) { {uuid: Random.uuid} }
        let!(:old_uuid) { task.uuid }

        it 'enqueues an NbpSyncJob for the old uuid' do
          expect { update }.to have_enqueued_job(NbpSyncJob).with(old_uuid)
        end
      end
    end

    context 'when updating a private task' do
      let(:access_level) { :private }
      let(:new_attributes) { {title: 'some new title'} }

      it 'does not enqueue an NbpSyncJob' do
        expect { update }.not_to have_enqueued_job(NbpSyncJob)
      end

      context 'when updating the uuid' do
        let(:new_attributes) { {uuid: Random.uuid} }

        it 'does not enqueue an NbpSyncJob' do
          expect { update }.not_to have_enqueued_job(NbpSyncJob)
        end
      end
    end

    context 'when changing the access level from private to public' do
      let(:access_level) { :private }
      let(:new_attributes) { {access_level: :public} }

      it 'enqueues an NbpSyncJob' do
        expect { update }.to have_enqueued_job(NbpSyncJob).with(task.uuid)
      end

      context 'when also updating the uuid' do
        let(:new_attributes) { {access_level: :public, uuid: Random.uuid} }
        let!(:old_uuid) { task.uuid }

        it 'does not enqueue an NbpSyncJob for the old uuid' do
          expect { update }.not_to have_enqueued_job(NbpSyncJob).with(old_uuid)
        end
      end
    end

    context 'when changing the access level from public to private' do
      let(:access_level) { :public }
      let(:new_attributes) { {access_level: :private} }

      it 'enqueues an NbpSyncJob' do
        expect { update }.to have_enqueued_job(NbpSyncJob).with(task.uuid)
      end

      context 'when also updating the uuid' do
        let(:new_attributes) { {access_level: :private, uuid: Random.uuid} }
        let!(:old_uuid) { task.uuid }

        it 'enqueues an NbpSyncJob for the old uuid' do
          expect { update }.to have_enqueued_job(NbpSyncJob).with(old_uuid)
        end
      end
    end
  end
end
