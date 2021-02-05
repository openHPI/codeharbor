# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgrammingLanguage, type: :model do
  describe '#language_with_version' do
    subject { programming_language.language_with_version }

    let(:programming_language) { build(:programming_language, :ruby) }

    it { is_expected.to eql 'Ruby 3.0.0' }
  end
end
