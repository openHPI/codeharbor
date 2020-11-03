# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileType, type: :model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:file_extension) }
    it { is_expected.to validate_uniqueness_of(:file_extension) }
  end
end

