# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLinkPolicy do
  subject { described_class.new(user, account_link) }

  let(:account_link_user) { create(:user) }
  let(:account_link) { create(:account_link, user: account_link_user, shared_users:) }
  let(:shared_users) { [] }

  context 'without a user' do
    it { expect { described_class.new(nil, account_link) }.to raise_error(Pundit::NotAuthorizedError) }
  end

  context 'with a user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_only_actions(%i[new]) }

    context 'when user is listed as shared_user' do
      let(:shared_users) { [user] }

      it { is_expected.to permit_only_actions(%i[new show remove_shared_user use]) }
    end

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to permit_all_actions }
    end

    context 'when account_link is from user' do
      let(:account_link_user) { user }

      it { is_expected.to permit_all_actions }
    end
  end
end
