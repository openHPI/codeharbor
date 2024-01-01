# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagePolicy do
  subject { described_class.new(user, message) }

  let(:recipient) { create(:user) }
  let(:sender) { create(:user) }
  let(:message) { create(:message, sender:, recipient:) }

  context 'without a user' do
    it { expect { described_class.new(nil, message) }.to raise_error(Pundit::NotAuthorizedError) }
  end

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

      context 'when user got a message from recipient' do
        before { create(:message, sender: recipient, recipient: user) }

        it { is_expected.to permit_all_actions }
      end
    end
  end
end
