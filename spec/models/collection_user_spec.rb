# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionUser do
  describe 'validations' do
    subject { build(:collection_user) }

    it { is_expected.to belong_to(:collection) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:collection_id) }
  end
end
