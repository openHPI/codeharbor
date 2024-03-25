# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OmniAuth::NonceStore do
  let(:nonce) { SecureRandom.hex }
  let(:value) { 'value' }
  let(:cache) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    stub_const('OmniAuth::NonceStore::MAXIMUM_AGE', 1)
    allow(Devise).to receive(:friendly_token).and_return(nonce)
    allow(described_class).to receive(:cache).and_return(cache)
  end

  describe '.add' do
    it 'stores a nonce in the cache' do
      expect(cache).to receive(:write)
      described_class.add(value)
    end

    it 'returns the nonce' do
      expect(described_class.add(value)).to eq(nonce)
    end
  end

  describe '.delete' do
    it 'deletes a nonce from the cache' do
      expect(cache).to receive(:delete)
      described_class.add(value)
      described_class.delete(nonce)
    end
  end

  describe '.read' do
    it 'returns the value for present nonces' do
      described_class.add(value)
      expect(described_class.read(nonce)).to eq value
    end

    it 'returns nil for expired nonces' do
      described_class.add(value)
      expect(described_class.read(nonce)).to eq value
      sleep(OmniAuth::NonceStore::MAXIMUM_AGE)
      expect(described_class.read(nonce)).to be_nil
    end

    it 'returns nil for absent nonces' do
      expect(described_class.read(nonce)).to be_nil
    end

    it 'returns nil for deleted nonces' do
      described_class.add(value)
      expect(described_class.read(nonce)).to eq value
      described_class.delete(nonce)
      expect(described_class.read(nonce)).to be_nil
    end
  end

  describe '.pop' do
    it 'returns the value for present nonces' do
      described_class.add(value)
      expect(described_class.pop(nonce)).to eq value
    end

    it 'returns nil for expired nonces' do
      described_class.add(value)
      expect(described_class.pop(nonce)).to eq value
      sleep(OmniAuth::NonceStore::MAXIMUM_AGE)
      expect(described_class.pop(nonce)).to be_nil
    end

    it 'returns nil for absent nonces' do
      expect(described_class.pop(nonce)).to be_nil
    end

    it 'deletes the nonce' do
      described_class.add(value)
      expect(described_class.pop(nonce)).to eq value
      expect(described_class.pop(nonce)).to be_nil
    end
  end

  describe '.cache' do
    before do
      allow(described_class).to receive(:cache).and_call_original
    end

    it 'returns a file store' do
      expect(described_class.cache).to be_a(ActiveSupport::Cache::FileStore)
    end
  end
end
