# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupPolicy do
  subject { described_class.new(user, group) }

  let(:user) { nil }
  let(:group_user) { create(:user) }
  let!(:group) { create(:group) }
  let(:role) { :confirmed_member }

  before do
    group.add(group_user, role:)
    group.reload
  end

  context 'with a user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_only_actions(%i[index new request_access]) }

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to forbid_only_actions(%i[leave]) }

      context 'when admin is in group' do
        before { group.add(user) }

        it { is_expected.to forbid_only_actions(%i[request_access]) }
      end
    end

    context 'when user is in group' do
      let(:group_user) { user }

      it { is_expected.to permit_only_actions(%i[index new show members leave]) }

      context 'when user is admin of the group' do
        let(:role) { 'admin' }

        it { is_expected.to forbid_only_actions(%i[request_access]) }
      end
    end
  end
end
