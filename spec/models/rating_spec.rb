# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating do
  describe 'validations' do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_numericality_of(:rating).only_integer.is_less_than_or_equal_to(5).is_greater_than(0) }
  end
end
