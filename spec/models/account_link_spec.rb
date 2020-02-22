# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLink, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:account_link_user) { create(:user) }
    let(:account_link) { create(:account_link, user: account_link_user, shared_users: shared_users) }
    let(:shared_users) { [] }

    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }
    it { is_expected.not_to be_able_to(:view, account_link) }
    it { is_expected.not_to be_able_to(:remove_shared_user, account_link) }
    it { is_expected.not_to be_able_to(:add_shared_user, account_link) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }
      it { is_expected.not_to be_able_to(:view, account_link) }
      it { is_expected.not_to be_able_to(:remove_shared_user, account_link) }
      it { is_expected.not_to be_able_to(:add_shared_user, account_link) }

      context 'when user is listed as shared_user' do
        let(:shared_users) { [user] }

        it { is_expected.to be_able_to(:view, account_link) }
        it { is_expected.to be_able_to(:show, account_link) }
        it { is_expected.not_to be_able_to(:remove_shared_user, account_link) }
        it { is_expected.not_to be_able_to(:add_shared_user, account_link) }
      end

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, account_link) }
      end

      context 'when account_link is from user' do
        let(:account_link_user) { user }

        it { is_expected.to be_able_to(:view, account_link) }
        it { is_expected.to be_able_to(:create, account_link) }
        it { is_expected.to be_able_to(:show, account_link) }
        it { is_expected.to be_able_to(:update, account_link) }
        it { is_expected.to be_able_to(:destroy, account_link) }
        it { is_expected.to be_able_to(:remove_shared_user, account_link) }
        it { is_expected.to be_able_to(:add_shared_user, account_link) }
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:check_uuid_url) }
    it { is_expected.to validate_presence_of(:push_url) }
    it { is_expected.to validate_presence_of(:api_key) }
    it { is_expected.to belong_to(:user) }
  end

  describe '#usable_by?' do
    subject(:usable_by) { account_link.usable_by?(user) }

    let(:account_link) { create(:account_link, user: another_user) }

    let(:another_user) { create(:user) }
    let(:user) { create(:user) }

    it { is_expected.to be false }

    context 'when user owns account_link' do
      let(:another_user) { user }

      it { is_expected.to be true }
    end

    context 'when account_link is shared with user' do
      before { create(:account_link_user, account_link: account_link, user: user) }

      it { is_expected.to be true }
    end
  end
end
