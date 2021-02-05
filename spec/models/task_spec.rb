# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
    it { is_expected.to belong_to(:user) }
  end
end
