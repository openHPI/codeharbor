# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enmeshed::Attribute do
  describe '#to_h' do
    subject(:attribute) { described_class.new(type: 'test', value: 'test', owner: 'owner') }

    it 'raises NotImplementedError' do
      expect { attribute.to_h }.to raise_error(NotImplementedError)
    end
  end
end
