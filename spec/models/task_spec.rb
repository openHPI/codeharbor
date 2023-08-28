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

    let(:days) { '' }
    let!(:new_task) { create(:task, created_at: 1.week.ago) }
    let!(:old_task) { create(:task, created_at: 4.weeks.ago) }

    it { is_expected.to include new_task, old_task }

    context 'when task days is 0' do
      let(:days) { 0 }

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

  describe '.min_stars' do
    let(:user) { create(:user) }
    let!(:good_task) { create(:task, user:, ratings: create_list(:rating, 1, :good)) }
    let!(:bad_task) { create(:task, user:, ratings: create_list(:rating, 1, :bad)) }
    let!(:unrated_task) { create(:task, user:, ratings: []) }

    it 'filters the tasks correctly' do
      expect(described_class.where(user:).min_stars(3)).to contain_exactly(good_task)
    end

    it 'includes unrated tasks when filtering after min 0 stars' do
      expect(described_class.where(user:).min_stars(0)).to contain_exactly(unrated_task, bad_task, good_task)
    end
  end

  describe '.sort_by_overall_rating_asc' do
    let(:user) { create(:user) }
    let!(:good_task) { create(:task, user:, ratings: create_list(:rating, 1, :good)) }
    let!(:bad_task) { create(:task, user:, ratings: create_list(:rating, 1, :bad)) }
    let!(:unrated_task) { create(:task, user:, ratings: []) }

    it 'orders the tasks correctly' do
      expect(described_class.where(user:).sort_by_overall_rating_asc).to match [unrated_task, bad_task, good_task]
    end
  end

  describe '.sort_by_overall_rating_desc' do
    let(:user) { create(:user) }
    let!(:good_task) { create(:task, user:, ratings: create_list(:rating, 1, :good)) }
    let!(:bad_task) { create(:task, user:, ratings: create_list(:rating, 1, :bad)) }
    let!(:unrated_task) { create(:task, user:, ratings: []) }

    it 'orders the tasks correctly' do
      expect(described_class.where(user:).sort_by_overall_rating_desc).to match [good_task, bad_task, unrated_task]
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

      context 'when change_title is false' do
        subject(:clean_duplicate) { task.clean_duplicate(user, false) }

        it 'has the same title' do
          expect(clean_duplicate.title).to eq('title')
        end
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

  describe '#all_files' do
    subject(:all_files) { task.all_files }

    let(:task) { create(:task, files:, model_solutions:, tests:) }
    let(:files) { build_list(:task_file, 1) }
    let(:model_solutions) do
      build_list(:model_solution, 2) do |model_solution|
        model_solution.files = build_list(:task_file, 3)
      end
    end
    let(:tests) do
      build_list(:test, 4) do |test|
        test.files = build_list(:task_file, 5)
      end
    end

    it { is_expected.to have_attributes(size: 27) }

    context 'with specific task_files' do
      let(:model_solutions) { build_list(:model_solution, 1, files: model_solution_files) }
      let(:model_solution_files) { build_list(:task_file, 3) }
      let(:tests) { build_list(:test, 1, files: test_files) }
      let(:test_files) { build_list(:task_file, 4) }

      it { is_expected.to match_array(files + model_solution_files + test_files) }
    end

    context 'when all_files is called again' do
      before do
        all_files
        task.tests.destroy_all
        task.model_solutions.destroy_all
      end

      it 'returns the cached result' do
        expect(all_files).to have_attributes(size: 27)
      end

      context 'with cache: false' do
        it 'returns the correct result' do
          expect(task.all_files(cached: false)).to have_attributes(size: 1)
        end
      end
    end
  end

  describe '#parent' do
    subject(:parent) { task.parent }

    let(:task) { create(:task, parent_uuid: p_uuid) }
    let(:p_uuid) { nil }
    let(:parent_task) { create(:task) }

    context 'when task has no parent' do
      it 'returns nil' do
        expect(parent).to be_nil
      end
    end

    context 'when task has an unknown parent_uuid' do
      let(:p_uuid) { :invalid }

      it 'returns nil' do
        expect(parent).to be_nil
      end
    end

    context 'when task has a valid parent_uuid' do
      let(:p_uuid) { parent_task.uuid }

      it 'returns the parent_task' do
        expect(parent).to eq(parent_task)
      end
    end
  end

  describe '#parent_of?' do
    subject(:parent_of) { parent_task.parent_of?(task) }

    let(:task) { create(:task, parent_uuid: p_uuid) }
    let(:p_uuid) { nil }
    let(:parent_task) { create(:task) }

    context 'when task has no parent' do
      it 'returns false' do
        expect(parent_of).to be(false)
      end
    end

    context 'when task has different parent' do
      let(:other_task) { create(:task) }
      let(:p_uuid) { other_task.uuid }

      it 'returns false' do
        expect(parent_of).to be(false)
      end
    end

    context 'when parent_task is parent' do
      let(:p_uuid) { parent_task.uuid }

      it 'returns true' do
        expect(parent_of).to be(true)
      end
    end
  end
end
