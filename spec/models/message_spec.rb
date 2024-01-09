# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe Message do
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
