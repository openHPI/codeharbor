# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe Message, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:recipient) { create(:user) }
    let(:sender) { create(:user) }
    let(:message) { create(:message, sender: sender, recipient: recipient) }
    let(:role) { 'member' }

    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }

    it { is_expected.not_to be_able_to(:create, message) }
    it { is_expected.not_to be_able_to(:show, message) }
    it { is_expected.not_to be_able_to(:reply, message) }
    it { is_expected.not_to be_able_to(:delete, message) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }

      it { is_expected.not_to be_able_to(:show, message) }
      it { is_expected.not_to be_able_to(:reply, message) }
      it { is_expected.not_to be_able_to(:delete, message) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, message) }
      end

      context 'when user is recipient' do
        let(:user) { recipient }

        it { is_expected.to be_able_to(:create, described_class) }
        it { is_expected.to be_able_to(:new, described_class) }
        it { is_expected.not_to be_able_to(:manage, described_class) }

        it { is_expected.to be_able_to(:show, message) }
        it { is_expected.to be_able_to(:reply, message) }
        it { is_expected.to be_able_to(:delete, message) }
      end

      context 'when user is sender' do
        let(:user) { sender }

        it { is_expected.to be_able_to(:create, described_class) }
        it { is_expected.to be_able_to(:new, described_class) }
        it { is_expected.not_to be_able_to(:manage, described_class) }

        it { is_expected.to be_able_to(:show, message) }
        it { is_expected.not_to be_able_to(:reply, message) }
        it { is_expected.to be_able_to(:delete, message) }
      end
    end
  end
end
