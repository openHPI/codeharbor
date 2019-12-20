# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportFileCache, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to :user }
  end
end
