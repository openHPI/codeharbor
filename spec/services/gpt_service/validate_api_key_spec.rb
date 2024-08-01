# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GptService::ValidateApiKey do
  let(:openai_api_key) { 'valid_api_key' }
  let(:openai_client) { OpenAI::Client.new(access_token: openai_api_key) }
  let(:openai_models) { instance_double(OpenAI::Models, list: {'data' => models_list}) }
  let(:models_list) { [{'id' => 'model-id'}] }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    allow(openai_client).to receive(:models).and_return(openai_models)
  end

  describe '.new' do
    subject(:validate_api_key) { described_class.new(openai_api_key:) }

    it 'assigns the client for OpenAI' do
      expect(validate_api_key.instance_variable_get(:@client)).to be openai_client
    end

    it 'stores the OpenAI API key in the client' do
      expect(validate_api_key.instance_variable_get(:@client).access_token).to eq openai_api_key
    end

    context 'when API key is missing' do
      let(:openai_api_key) { nil }

      it 'raises InvalidApiKeyError' do
        expect { validate_api_key }.to raise_error(Gpt::Error::InvalidApiKey)
      end
    end
  end

  describe '#call' do
    subject(:validate_api_key) { described_class.call(openai_api_key:) }

    it 'does not raise an error' do
      expect { validate_api_key }.not_to raise_error
    end

    context 'when model list is empty' do
      let(:models_list) {}

      it 'raises correct error' do
        expect { validate_api_key }.to raise_error(Gpt::Error::InvalidApiKey)
      end
    end

    context 'when API key is invalid' do
      let(:openai_api_key) { 'invalid_api_key' }

      before do
        allow(openai_models).to receive(:list).and_raise(Faraday::UnauthorizedError)
      end

      it 'raises InvalidApiKeyError' do
        expect { validate_api_key }.to raise_error(Gpt::Error::InvalidApiKey)
      end
    end

    context 'when OpenAI is not responding' do
      before do
        allow(openai_models).to receive(:list).and_raise(Faraday::Error)
      end

      it 'raises InternalServerError' do
        expect { validate_api_key }.to raise_error(Gpt::Error::InternalServerError)
      end
    end

    context 'when the network connection is broken' do
      before do
        allow(openai_models).to receive(:list).and_raise(EOFError)
      end

      it 'raises an error' do
        expect { validate_api_key }.to raise_error(Gpt::Error)
      end
    end
  end
end
