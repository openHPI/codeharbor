# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enmeshed::Attribute do
  describe '#to_h' do
    subject(:attribute) { described_class.new(type: 'test', value: 'test', owner: 'owner') }

    it 'raises NotImplementedError' do
      expect { attribute.to_h }.to raise_error(NotImplementedError)
    end
  end

  describe '.parse' do
    subject(:parsed_attribute) { described_class.parse(content) }

    let(:content) { {content: {'@type': 'Attribute', owner: ''}} }

    context 'with non-API-compliant content' do
      it 'raises an error and logs it' do
        expect(Rails.logger).to receive(:debug) do |&block|
          expect(block).to be_a(Proc)
          expect(block.call).to match(/Invalid Attribute schema:/)
        end
        expect { parsed_attribute }.to raise_error(Enmeshed::ConnectorError, /Invalid Attribute schema:/)
      end
    end
  end
end
