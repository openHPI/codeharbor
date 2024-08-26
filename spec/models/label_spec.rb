# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Label do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#to_s' do
    let(:label_name) { 'Test Label' }
    let(:label) { described_class.new(name: label_name) }

    it 'returns the label name' do
      expect(label.to_s).to eq label_name
    end
  end
end
