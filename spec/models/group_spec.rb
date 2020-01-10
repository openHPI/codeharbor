# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe Group, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:group_user) { create(:user) }
    let(:group) { create(:group) }
    let(:role) { 'member' }

    before { group.add(group_user, as: role) }

    it { is_expected.not_to be_able_to(:index, described_class) }
    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }

    it { is_expected.not_to be_able_to(:request_access, group) }
    it { is_expected.not_to be_able_to(:view, group) }
    it { is_expected.not_to be_able_to(:show, group) }
    it { is_expected.not_to be_able_to(:members, group) }
    it { is_expected.not_to be_able_to(:leave, group) }
    it { is_expected.not_to be_able_to(:crud, group) }
    it { is_expected.not_to be_able_to(:remove_exercise, group) }
    it { is_expected.not_to be_able_to(:grant_access, group) }
    it { is_expected.not_to be_able_to(:delete_from_group, group) }
    it { is_expected.not_to be_able_to(:deny_access, group) }
    it { is_expected.not_to be_able_to(:make_admin, group) }
    it { is_expected.not_to be_able_to(:add_account_link_to_member, group) }
    it { is_expected.not_to be_able_to(:remove_account_link_from_member, group) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:index, described_class) }
      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }

      it { is_expected.to be_able_to(:request_access, group) }
      it { is_expected.not_to be_able_to(:view, group) }
      it { is_expected.not_to be_able_to(:show, group) }
      it { is_expected.not_to be_able_to(:members, group) }
      it { is_expected.not_to be_able_to(:leave, group) }
      it { is_expected.not_to be_able_to(:crud, group) }
      it { is_expected.not_to be_able_to(:remove_exercise, group) }
      it { is_expected.not_to be_able_to(:grant_access, group) }
      it { is_expected.not_to be_able_to(:delete_from_group, group) }
      it { is_expected.not_to be_able_to(:deny_access, group) }
      it { is_expected.not_to be_able_to(:make_admin, group) }
      it { is_expected.not_to be_able_to(:add_account_link_to_member, group) }
      it { is_expected.not_to be_able_to(:remove_account_link_from_member, group) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, group) }
      end

      context 'when group is from user' do
        let(:group_user) { user }

        it { is_expected.to be_able_to(:index, described_class) }
        it { is_expected.to be_able_to(:create, described_class) }
        it { is_expected.to be_able_to(:new, described_class) }
        it { is_expected.not_to be_able_to(:manage, described_class) }

        it { is_expected.not_to be_able_to(:request_access, group) }
        it { is_expected.to be_able_to(:view, group) }
        it { is_expected.to be_able_to(:show, group) }
        it { is_expected.to be_able_to(:members, group) }
        it { is_expected.to be_able_to(:leave, group) }
        it { is_expected.not_to be_able_to(:crud, group) }
        it { is_expected.not_to be_able_to(:remove_exercise, group) }
        it { is_expected.not_to be_able_to(:grant_access, group) }
        it { is_expected.not_to be_able_to(:delete_from_group, group) }
        it { is_expected.not_to be_able_to(:deny_access, group) }
        it { is_expected.not_to be_able_to(:make_admin, group) }
        it { is_expected.not_to be_able_to(:add_account_link_to_member, group) }
        it { is_expected.not_to be_able_to(:remove_account_link_from_member, group) }

        context 'when user is admin of the group' do
          let(:role) { 'admin' }

          it { is_expected.to be_able_to(:index, described_class) }
          it { is_expected.to be_able_to(:create, described_class) }
          it { is_expected.to be_able_to(:new, described_class) }
          it { is_expected.not_to be_able_to(:manage, described_class) }

          it { is_expected.not_to be_able_to(:request_access, group) }
          it { is_expected.to be_able_to(:view, group) }
          it { is_expected.to be_able_to(:show, group) }
          it { is_expected.to be_able_to(:members, group) }
          it { is_expected.to be_able_to(:leave, group) }
          it { is_expected.to be_able_to(:crud, group) }
          it { is_expected.to be_able_to(:remove_exercise, group) }
          it { is_expected.to be_able_to(:grant_access, group) }
          it { is_expected.to be_able_to(:delete_from_group, group) }
          it { is_expected.to be_able_to(:deny_access, group) }
          it { is_expected.to be_able_to(:make_admin, group) }
          it { is_expected.to be_able_to(:add_account_link_to_member, group) }
          it { is_expected.to be_able_to(:remove_account_link_from_member, group) }
        end
      end
    end
  end
end
