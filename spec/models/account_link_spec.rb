# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLink do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:check_uuid_url) }
    it { is_expected.to validate_presence_of(:push_url) }
    it { is_expected.to validate_presence_of(:api_key) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:proforma_version).in_array(%w[2.1 2.0]).allow_nil }
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
      before { create(:account_link_user, account_link:, user:) }

      it { is_expected.to be true }
    end
  end
end
