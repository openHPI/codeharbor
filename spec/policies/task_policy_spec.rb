# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskPolicy do
  subject { described_class.new(user, task) }

  let(:task_user) { create(:user) }
  let(:groups) { [] }
  let(:access_level) { :private }
  let(:task) { create(:task, user: task_user, access_level:, groups:) }

  context 'without a user' do
    let(:user) { nil }

    context 'when task is private' do
      let(:access_level) { :private }

      it { expect(task.lom_showable_by?(user)).to be false }
      it { is_expected.to forbid_all_actions }
    end

    context 'when task is public' do
      let(:access_level) { :public }

      it { expect(task.lom_showable_by?(user)).to be true }
      it { is_expected.to permit_only_actions(%i[show download]) }
    end
  end

  context 'with a user' do
    let(:user) { create(:user) }
    let(:generic_user_permissions) { %i[index new import_start import_confirm import_uuid_check import_external] }

    it { is_expected.to permit_only_actions(generic_user_permissions) }
    it { expect(task.lom_showable_by?(user)).to be false }

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to permit_all_actions }
      it { expect(task.lom_showable_by?(user)).to be true }
    end

    context 'when task is from user' do
      let(:task_user) { user }

      it { is_expected.to permit_all_actions }
      it { expect(task.lom_showable_by?(user)).to be true }
    end

    context 'when task has access_level "public"' do
      let(:task_user) { create(:user) }
      let(:access_level) { :public }

      it { is_expected.to permit_only_actions(generic_user_permissions + %i[show export_external_start export_external_check export_external_confirm download add_to_collection duplicate]) }
      it { expect(task.lom_showable_by?(user)).to be true }
    end

    context 'when task is "private" and in same group' do
      let(:access_level) { :private }
      let(:user) { create(:user) }

      let(:role) { :confirmed_member }
      let(:group_memberships) { [build(:group_membership, :with_admin), build(:group_membership, user:, role:)] }
      let(:groups) { create_list(:group, 1, group_memberships:) }

      let(:group_member_permissions) { generic_user_permissions + %i[edit update duplicate show export_external_start export_external_check export_external_confirm download add_to_collection duplicate] }

      it { is_expected.to permit_only_actions(group_member_permissions) }
      it { expect(task.lom_showable_by?(user)).to be true }

      context 'when user is group-admin' do
        let(:role) { :admin }

        it { is_expected.to permit_only_actions(group_member_permissions + %i[destroy]) }
      end
    end
  end
end
