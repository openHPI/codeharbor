# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupPolicy do
  subject { described_class.new(user, group) }

  let!(:group) { create(:group, group_memberships:) }
  let(:group_user) { create(:user) }
  let(:role) { :confirmed_member }
  let(:group_admin) { create(:user) }
  let(:group_memberships) { [build(:group_membership, user: group_admin, role: :admin), build(:group_membership, user: group_user, role:)] }

  context 'without a user' do
    it { expect { described_class.new(nil, group) }.to raise_error(Pundit::NotAuthorizedError) }
  end

  context 'with a user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_only_actions(%i[index new request_access]) }

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to forbid_only_actions(%i[leave]) }

      context 'when admin is in group' do
        let(:group_user) { user }

        it { is_expected.to forbid_only_actions(%i[request_access]) }
      end
    end

    context 'when user is in group' do
      let(:group_user) { user }

      it { is_expected.to permit_only_actions(%i[index new show members leave]) }

      context 'when user is admin of the group' do
        let(:role) { :admin }

        it { is_expected.to forbid_only_actions(%i[request_access]) }
      end
    end
  end
end
