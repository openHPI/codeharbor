# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLink, type: :model do
  it { is_expected.to validate_presence_of(:check_uuid_url) }
  it { is_expected.to validate_presence_of(:push_url) }
  it { is_expected.to validate_presence_of(:api_key) }
  it { is_expected.to belong_to(:user) }
end
