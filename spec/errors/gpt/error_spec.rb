# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gpt::Error do
  it 'has localized messages for all error classes' do
    error_classes = described_class.descendants || []
    sample_errors = error_classes.map(&:new)
    expect { sample_errors.map(&:localized_message) }.not_to raise_exception
  end
end
