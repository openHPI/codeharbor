# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe Message do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:recipient) { create(:user) }
    let(:sender) { create(:user) }
    let(:message) { create(:message, sender:, recipient:) }
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

  describe 'destroy_hook' do
    let!(:message) { create(:message) }

    it 'does not delete message' do
      message.save
      expect(message).not_to be_destroyed
    end

    context 'when one status is d' do
      it 'does not delete message' do
        message.sender_status = 'd'
        message.save

        expect(message).not_to be_destroyed
      end
    end

    context 'when both statuses are d' do
      it 'does not delete message' do
        message.sender_status = 'd'
        message.recipient_status = 'd'
        message.save

        expect(message).to be_destroyed
      end
    end
  end

  describe '#mark_as_deleted' do
    subject(:mark_as_deleted) { message.mark_as_deleted(user) }

    let(:user) { build(:user) }
    let(:message) { build(:message, sender:, recipient:) }
    let(:sender) {}
    let(:recipient) {}

    it 'does not set recipient_status to d' do
      expect { mark_as_deleted }.not_to change(message, :recipient_status)
    end

    it 'does not set sender_status to d' do
      expect { mark_as_deleted }.not_to change(message, :sender_status)
    end

    context 'when user is sender' do
      let(:sender) { user }

      it 'sets sender_status to d' do
        expect { mark_as_deleted }.to change(message, :sender_status).to('d')
      end

      it 'does not set recipient_status to d' do
        expect { mark_as_deleted }.not_to change(message, :recipient_status)
      end
    end

    context 'when user is recipient' do
      let(:recipient) { user }

      it 'sets recipient_status to d' do
        expect { mark_as_deleted }.to change(message, :recipient_status).to('d')
      end

      it 'does not set sender_status to d' do
        expect { mark_as_deleted }.not_to change(message, :sender_status)
      end
    end

    context 'when user is sender and recipient' do
      let(:sender) { user }
      let(:recipient) { user }

      it 'sets sender_status to d' do
        expect { mark_as_deleted }.to change(message, :sender_status).to('d')
      end

      it 'sets recipient_status to d' do
        expect { mark_as_deleted }.to change(message, :recipient_status).to('d')
      end
    end
  end
end
