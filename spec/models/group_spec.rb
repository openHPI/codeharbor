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
        it { is_expected.not_to be_able_to(:leave, group) }

        context 'when admin is in group' do
          before { group.add(user) }

          it { is_expected.not_to be_able_to(:request_access, group) }
          it { is_expected.to be_able_to(:leave, group) }
        end
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

  describe 'validations' do
    let(:group) { create(:group, users: users) }
    let(:users) { [user] }
    let(:user) { create(:user) }

    it 'is valid' do
      expect(group.valid?).to be true
    end

    context 'when user get removed from group' do
      before { group.users.destroy(user) }

      it 'is not valid' do
        expect(group.valid?).to be false
      end

      it 'has correct error' do
        group.validate
        expect(group.errors.full_messages).to include I18n.t('groups.no_admin_validation')
      end
    end
  end

  describe '#remove_member' do
    let(:group) { create(:group, users: group_users) }
    let(:group_users) { [admin, user] }
    let(:admin) { create(:user) }
    let(:user) { create(:user) }

    it 'deletes member' do
      expect { group.remove_member(user) }.to change(group.users, :count).by(-1)
    end

    it 'does not delete admin' do
      expect { group.remove_member(admin) }.to raise_error(ActiveRecord::RecordInvalid).and change(group.users, :count).by(0)
    end

    context 'when group has another admin' do
      before { group.make_admin(create(:user)) }

      it 'allows deletion of admin' do
        expect { group.remove_member(admin) }.to change(group.users, :count).by(-1)
      end
    end
  end

  describe '.create_with_admin' do
    subject(:create_with_admin) { described_class.create_with_admin(params, user) }

    let(:params) { {name: name} }
    let(:user) { create(:user) }
    let(:name) { 'name' }

    it 'creates a group' do
      expect { create_with_admin }.to change(described_class, :count).by(1)
    end

    it 'sets user as admin of created group' do
      expect(create_with_admin.admin?(user)).to be true
    end

    context 'without user' do
      let(:user) {}

      it 'does not create a group' do
        expect { create_with_admin }.not_to change(described_class, :count)
      end
    end

    context 'without name' do
      let(:name) {}

      it 'does not create a group' do
        expect { create_with_admin }.not_to change(described_class, :count)
      end
    end
  end
end
