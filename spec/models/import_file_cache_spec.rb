# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportFileCache do
  describe 'validations' do
    it { is_expected.to belong_to :user }
  end
end
