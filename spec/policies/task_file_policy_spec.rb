# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFilePolicy do
  subject { described_class.new(user, task_file) }

  let(:task_user) { create(:user) }
  let(:groups) { [] }

  let(:access_level) { :private }
  let(:task) { create(:task, user: task_user, access_level:, groups:) }
  let(:fileable) { task }
  let(:task_file) { create(:task_file, fileable:) }

  context 'without a user' do
    it { expect { described_class.new(nil, task_file) }.to raise_error(Pundit::NotAuthorizedError) }
  end

  context 'with a user and private task' do
    let(:user) { create(:user) }

    it { is_expected.to forbid_all_actions }

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to permit_all_actions }
    end

    context 'when task is from user' do
      let(:task_user) { user }

      it { is_expected.to permit_only_actions(%i[download_attachment extract_text_data]) }
    end

    context 'when task is in same group' do
      let(:user) { create(:user) }
      let(:group_memberships) { [build(:group_membership, :with_admin), build(:group_membership, user:, role: :confirmed_member)] }
      let(:groups) { create_list(:group, 1, group_memberships:) }

      it { is_expected.to permit_only_actions(%i[download_attachment extract_text_data]) }
    end

    context 'when task_file belongs to a test' do
      let(:fileable) { create(:test, task:) }

      it { is_expected.to forbid_all_actions }

      context 'when task is from user' do
        let(:task_user) { user }

        it { is_expected.to permit_only_actions(%i[download_attachment extract_text_data]) }
      end
    end
  end

  context 'with a user and public task' do
    let(:user) { create(:user) }
    let(:access_level) { :public }

    # why only permit downloading attachments when the text could be extracted after downloading anyway?
    it { is_expected.to permit_only_actions(%i[download_attachment]) }

    context 'when task is from user' do
      let(:task_user) { user }

      it { is_expected.to permit_only_actions(%i[download_attachment extract_text_data]) }
    end

    context 'when user is in group' do
      let(:user) { create(:user) }
      let(:group_memberships) { [build(:group_membership, :with_admin), build(:group_membership, user:, role: :confirmed_member)] }
      let(:groups) { create_list(:group, 1, group_memberships:) }

      it { is_expected.to permit_only_actions(%i[download_attachment extract_text_data]) }
    end

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to permit_all_actions }
    end
  end
end
