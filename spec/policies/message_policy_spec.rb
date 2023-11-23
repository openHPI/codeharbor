# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagePolicy do
  subject { described_class.new(user, message) }

  let(:user) { nil }
  let(:recipient) { create(:user) }
  let(:sender) { create(:user) }
  let(:message) { create(:message, sender:, recipient:) }
  let(:role) { 'member' }

  context 'with a user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_only_actions(%i[index new]) }

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to permit_all_actions }
    end

    context 'when user is recipient' do
      let(:user) { recipient }

      it { is_expected.to permit_only_actions(%i[index new destroy]) }
    end

    context 'when user is sender' do
      let(:user) { sender }

      it { is_expected.to forbid_only_actions(%i[reply]) }
    end
  end
end
