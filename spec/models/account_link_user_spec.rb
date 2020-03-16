# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLinkUser, type: :model do
  describe '#valid?' do
    subject { build(:account_link_user, account_link: account_link, user: user).valid? }

    let(:account_link) { build(:account_link) }
    let(:user) { build(:user) }

    it { is_expected.to be true }

    context 'without user' do
      let(:user) {}

      it { is_expected.to be false }
    end

    context 'without account_link' do
      let(:account_link) {}

      it { is_expected.to be false }
    end

    context 'with another account_link_user' do
      before { create(:account_link_user, user: user_2, account_link: account_link_2) }

      let(:account_link_2) { build(:account_link) }
      let(:user_2) { build(:user) }

      it { is_expected.to be true }

      context 'when user is the same' do
        let(:user_2) { user }

        it { is_expected.to be true }
      end

      context 'when account_link is the same' do
        let(:account_link_2) { account_link }

        it { is_expected.to be true }
      end

      context 'when account_link and user are the same' do
        let(:user_2) { user }
        let(:account_link_2) { account_link }

        it { is_expected.to be false }
      end
    end
  end
end
