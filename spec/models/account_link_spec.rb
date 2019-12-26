# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLink, type: :model do
  fdescribe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:account_link_user) { create(:user) }
    let(:account_link) { create(:account_link, user: account_link_user) }

    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }
    it { is_expected.not_to be_able_to(:view, account_link) }
    it { is_expected.not_to be_able_to(:remove_account_link, account_link) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }
      it { is_expected.not_to be_able_to(:view, account_link) }
      it { is_expected.not_to be_able_to(:remove_account_link, account_link) }

      context 'when account_link is from user' do
        let(:account_link_user) { user }

        it { is_expected.to be_able_to(:view, account_link) }
        it { is_expected.to be_able_to(:remove_account_link, account_link) }
        it { is_expected.to be_able_to(:manage, account_link) }
      end
    end

  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:check_uuid_url) }
    it { is_expected.to validate_presence_of(:push_url) }
    it { is_expected.to validate_presence_of(:api_key) }
    it { is_expected.to belong_to(:user) }
  end
end
