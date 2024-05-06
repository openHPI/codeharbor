# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to belong_to(:user) }
  end
end
