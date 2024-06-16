# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enmeshed::Connector do
  let(:connector) { described_class }

  describe '.parse_result' do
    let(:response) { Faraday::Response.new(body:) }
    let(:body) { '{"result": {"foo": "bar"}}' }

    it 'returns the parsed JSON' do
      expect(connector.send(:parse_result, response)).to eq(foo: 'bar')
    end

    context 'when the response is not successful' do
      let(:body) { '{"error": {"message": "foobar"}}' }

      it 'raises an error' do
        expect { connector.send(:parse_result, response) }.to raise_error(Enmeshed::ConnectorError)
      end
    end

    context 'when an invalid JSON is returned' do
      let(:body) { '"invalid{' }

      it 'raises an error' do
        expect { connector.send(:parse_result, response) }.to raise_error(Enmeshed::ConnectorError)
      end
    end
  end

  describe '.init_conn' do
    before do
      allow(User).to receive(:omniauth_providers).and_return([:nbp])
    end

    it 'returns a Faraday connection' do
      expect(connector.send(:init_conn)).to be_a(Faraday::Connection)
    end

    context 'when the config is invalid' do
      before do
        allow(User).to receive(:omniauth_providers).and_return([])
      end

      it 'raises an error' do
        expect { connector.send(:init_conn) }.to raise_error(Enmeshed::ConnectorError)
      end
    end
  end
end
